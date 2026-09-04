import 'dart:convert';
// このアプリはFlutter Web専用(モバイル/デスクトップ版は作らない)なので、
// ファイルのダウンロード・アップロードにdart:htmlを直接使う。
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import '../services/cloud_sync_service.dart';

/// バックアップの作成・復元を行う画面。
///
/// このアプリのデータは端末(ブラウザ)ごとにバラバラに保存されているため、
/// 別の端末でも同じ学習記録を使いたい場合は、ここでバックアップファイルを
/// 作成し、別の端末で読み込んでもらう必要がある。
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;
  final _passphraseController = TextEditingController();

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _exportBackup() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final data = service.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = utf8.encode(jsonString);
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'sharoushi_backup_$dateStr.json')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('バックアップファイルをダウンロードしました')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importBackup() async {
    final input = html.FileUploadInputElement()..accept = 'application/json,.json';
    input.click();
    await input.onChange.first;
    final files = input.files;
    if (files == null || files.isEmpty) return;

    setState(() => _busy = true);
    try {
      final reader = html.FileReader();
      reader.readAsText(files.first);
      await reader.onLoad.first;
      final content = reader.result as String;
      final data = jsonDecode(content) as Map<String, dynamic>;

      final service = ref.read(backupServiceProvider);
      await service.importData(data);
      if (!mounted) return;
      bumpDataRevision(ref);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('バックアップから復元しました')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('復元に失敗しました。正しいバックアップファイルか確認してください。')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _uploadToCloud() async {
    final passphrase = _passphraseController.text.trim();
    if (passphrase.isEmpty) return;

    setState(() => _busy = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final cloudSyncService = ref.read(cloudSyncServiceProvider);
      final data = backupService.exportData();
      await cloudSyncService.upload(passphrase, data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アップロードしました。別の端末でこの合言葉を入力してください')),
      );
    } on CloudSyncException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _downloadFromCloud() async {
    final passphrase = _passphraseController.text.trim();
    if (passphrase.isEmpty) return;

    setState(() => _busy = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final cloudSyncService = ref.read(cloudSyncServiceProvider);
      final data = await cloudSyncService.download(passphrase);
      await backupService.importData(data);

      if (!mounted) return;
      bumpDataRevision(ref);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クラウドから復元しました')),
      );
    } on BackupNotFoundException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('この合言葉のバックアップが見つかりません')),
      );
    } on CloudSyncException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('バックアップ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'このアプリの学習データ(過去問の回答履歴・復習予定・メモ・お気に入り)は、'
              '今使っている端末のブラウザだけに保存されています。\n\n'
              '別の端末(PC・スマホなど)でも同じ学習記録を続けたい場合は、この画面で'
              'バックアップファイルを作成し、別の端末側で「バックアップから復元」を'
              '行ってください。',
            ),
            const SizedBox(height: 24),
            _sectionTitle('バックアップを作成'),
            const SizedBox(height: 6),
            const Text('現在の学習データをファイル(.json)としてダウンロードします。'),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('バックアップを作成'),
              onPressed: _busy ? null : _exportBackup,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 32),
            _sectionTitle('バックアップから復元'),
            const SizedBox(height: 6),
            const Text(
              '以前ダウンロードしたバックアップファイルを選択して、学習データを復元します。'
              '同じ記録がある場合は、ファイルの内容で上書きされます。',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('バックアップから復元'),
              onPressed: _busy ? null : _importBackup,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 32),
            _sectionTitle('合言葉でスマホ・iPadと共有'),
            const SizedBox(height: 6),
            const Text(
              '好きな合言葉を決めて「クラウドにアップロード」すると、別の端末で'
              '同じ合言葉を入力して「クラウドから読み込む」だけでデータを復元できます。'
              'ファイルのダウンロード・アップロードは不要です。\n\n'
              '(合言葉を知っている人だけがデータを読み書きできますが、強い暗号化は'
              'していないため、他人に推測されにくい合言葉にしてください)',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passphraseController,
              decoration: const InputDecoration(
                labelText: '合言葉',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('クラウドにアップロード'),
              onPressed: _busy ? null : _uploadToCloud,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.cloud_download),
              label: const Text('クラウドから読み込む'),
              onPressed: _busy ? null : _downloadFromCloud,
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }
}

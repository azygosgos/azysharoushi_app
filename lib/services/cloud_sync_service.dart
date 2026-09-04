import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

/// アップロード先に、まだ何もデータが置かれていない場合の例外。
class BackupNotFoundException implements Exception {}

/// 通信エラーなど、それ以外の理由でアップロード/ダウンロードに失敗した場合の例外。
class CloudSyncException implements Exception {
  CloudSyncException(this.message);
  final String message;
}

/// 合言葉をもとに、クラウド(Cloudflare Workers + KV)経由で
/// バックアップデータ(BackupService.exportData()の戻り値)を送受信するサービス。
///
/// 合言葉そのものはサーバーに送らず、SHA-256でハッシュ化した値だけを
/// 送信・保存先キーとして使う(データ本文自体の暗号化はしていない、
/// 詳しくは cloudflare-worker/README_DEPLOY.md を参照)。
class CloudSyncService {
  static const _endpoint =
      'https://azysharoushi-backup.azygosgos.workers.dev/backup';

  String _keyFor(String passphrase) {
    final bytes = utf8.encode(passphrase.trim());
    return sha256.convert(bytes).toString();
  }

  Future<void> upload(String passphrase, Map<String, dynamic> data) async {
    final key = _keyFor(passphrase);
    final http.Response response;
    try {
      response = await http.put(
        Uri.parse('$_endpoint?key=$key'),
        body: jsonEncode(data),
      );
    } catch (_) {
      throw CloudSyncException('通信に失敗しました。インターネット接続を確認してください。');
    }
    if (response.statusCode != 200) {
      throw CloudSyncException('アップロードに失敗しました(エラーコード: ${response.statusCode})');
    }
  }

  Future<Map<String, dynamic>> download(String passphrase) async {
    final key = _keyFor(passphrase);
    final http.Response response;
    try {
      response = await http.get(Uri.parse('$_endpoint?key=$key'));
    } catch (_) {
      throw CloudSyncException('通信に失敗しました。インターネット接続を確認してください。');
    }
    if (response.statusCode == 404) {
      throw BackupNotFoundException();
    }
    if (response.statusCode != 200) {
      throw CloudSyncException('取得に失敗しました(エラーコード: ${response.statusCode})');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

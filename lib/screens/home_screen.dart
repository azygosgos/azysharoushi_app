import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_tip.dart';
import '../providers/home_providers.dart';
import '../providers/repository_providers.dart';
import '../widgets/menu_button.dart';
import '../widgets/stat_card.dart';
import 'article_list_screen.dart';
import 'question_screen.dart';
import 'quiz_start_screen.dart';
import 'subject_list_screen.dart';
import 'today_review_screen.dart';

/// 労働基準法の法律ID。法律は今のところこれ1つだけなので直接指定する。
/// (将来、法律が増えたら過去問演習と同様に法律選択画面を挟む形に変更する)
const String kRoudouKijunhouLawId = 'law_roudoukijunhou';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 画面が最初に表示された後に、通知代わりのメッセージや
    // 「今日のワンポイント」を出すかどうかを判定する。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTodayReviewMessage();
      _maybeShowDailyTip();
    });
  }

  /// アプリ起動時に「今日の復習が○問あります」と表示する
  /// (Web Push通知の代わりの、簡易的なお知らせ)。
  void _showTodayReviewMessage() {
    final reviewCount = ref.read(homeStatsProvider).todayReviewCount;
    if (reviewCount <= 0 || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('今日の復習が$reviewCount問あります')),
    );
  }

  Future<void> _maybeShowDailyTip() async {
    final service = ref.read(dailyTipServiceProvider);
    final now = DateTime.now();
    final shouldShow = await service.shouldShowToday(now);
    if (!shouldShow || !mounted) return;

    final tip = ref.read(todayTipProvider);
    if (tip == null) return;

    await service.markShownToday(now);
    if (!mounted) return;
    _showDailyTipDialog(tip);
  }

  void _showDailyTipDialog(DailyTip tip) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今日のワンポイント学習'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tip.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(tip.body),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (tip.relatedQuestionId != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuestionScreen(questionId: tip.relatedQuestionId!),
                  ),
                );
              }
            },
            child: const Text('詳しく見る'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String featureName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(featureName),
        content: const Text('この機能は今後のバージョンで実装予定です。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(homeStatsProvider);
    final accuracyText = stats.recentAccuracy == null
        ? '-'
        : '${(stats.recentAccuracy! * 100).round()}%';

    return Scaffold(
      appBar: AppBar(title: const Text('社労士試験 学習アプリ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: '今日の復習問題数',
                    value: '${stats.todayReviewCount}問',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: '今日の学習目標',
                    value: '${stats.dailyGoal}問',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: '今日解いた問題数',
                    value: '${stats.todayAnsweredCount}問',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    label: '直近の正答率',
                    value: accuracyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            MenuButton(
              label: '今日の復習を始める',
              icon: Icons.refresh,
              primary: true,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TodayReviewScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            MenuButton(
              label: '過去問演習',
              icon: Icons.edit_note,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubjectListScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: '〇×クイズ',
              icon: Icons.check_circle_outline,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuizStartScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: '法律・条文',
              icon: Icons.menu_book,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ArticleListScreen(
                      lawId: kRoudouKijunhouLawId,
                      lawName: '労働基準法',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: '苦手問題',
              icon: Icons.warning_amber,
              onPressed: () => _showComingSoon('苦手問題'),
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: '復習メモ',
              icon: Icons.sticky_note_2,
              onPressed: () => _showComingSoon('復習メモ一覧'),
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: '学習履歴',
              icon: Icons.bar_chart,
              onPressed: () => _showComingSoon('学習履歴'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hiveのボックス(保存領域)名を1箇所にまとめたもの。
///
/// ボックス名を変更する場合はここだけを直せばよい。
class HiveBoxes {
  HiveBoxes._();

  // --- 教材データ(assets/data/*.json から読み込んで保存する) ---
  static const subjects = 'subjects_box';
  static const topics = 'topics_box';
  static const laws = 'laws_box';
  static const articles = 'articles_box';
  static const questions = 'questions_box';
  static const dailyTips = 'daily_tips_box';
  static const sources = 'sources_box';

  // --- ユーザーの学習データ(端末に保存され続ける) ---
  static const attempts = 'attempts_box';
  static const reviewSchedules = 'review_schedules_box';
  static const notes = 'notes_box';
  static const favorites = 'favorites_box';

  /// 全ボックス名の一覧 (初期化処理でまとめてopenするために使う)
  static const all = [
    subjects,
    topics,
    laws,
    articles,
    questions,
    dailyTips,
    sources,
    attempts,
    reviewSchedules,
    notes,
    favorites,
  ];
}

/// SharedPreferences(簡易フラグ保存)で使うキー名
class PrefKeys {
  PrefKeys._();

  /// 教材データを読み込んだバージョン番号
  static const dataVersion = 'data_version';

  /// 「今日のワンポイント」を最後に表示した日付 (yyyy-MM-dd)
  static const lastTipShownDate = 'last_tip_shown_date';

  /// 今日のワンポイントとして表示中のID (同じ日は同じものを出す)
  static const todayTipId = 'today_tip_id';

  /// 1日の学習目標問題数
  static const dailyGoal = 'daily_goal';
}

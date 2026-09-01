/// 問題の出題形式
enum QuestionType {
  /// ○×問題
  trueFalse,
  /// 5肢択一
  fiveChoice,
  /// 選択式(将来対応)
  selection;

  static QuestionType fromJson(String value) {
    return QuestionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuestionType.trueFalse,
    );
  }

  String toJson() => name;
}

/// 試験対策上の重要度 (S:非常に頻出 / A:頻出 / B:時々出題 / C:出題頻度は低い)
enum Importance {
  s,
  a,
  b,
  c;

  static Importance fromJson(String value) {
    return Importance.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Importance.c,
    );
  }

  String toJson() => name;

  /// 画面表示用のラベル
  String get label => name.toUpperCase();
}

/// 回答後の理解度自己評価
enum Understanding {
  /// 余裕
  easy,
  /// 普通
  normal,
  /// 難しい
  hard;

  static Understanding fromJson(String value) {
    return Understanding.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Understanding.normal,
    );
  }

  String toJson() => name;

  String get label {
    switch (this) {
      case Understanding.easy:
        return '余裕';
      case Understanding.normal:
        return '普通';
      case Understanding.hard:
        return '難しい';
    }
  }
}

/// メモの対象種別
enum NoteTargetType {
  question,
  article;

  static NoteTargetType fromJson(String value) {
    return NoteTargetType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NoteTargetType.question,
    );
  }

  String toJson() => name;
}

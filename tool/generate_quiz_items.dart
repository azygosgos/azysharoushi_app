// assets/data/questions.json の5肢択一問題(fiveChoice)から、各選択肢を
// 独立した〇×クイズ問題(QuizItem)として切り出し、assets/data/quiz_items.json を生成する。
//
// 【使い方】questions.json を編集した後(過去問を追加した後など)、
// プロジェクトルートで次を実行すると、〇×クイズのデータが最新化されます。
//   dart run tool/generate_quiz_items.dart
//
// 【変換できない選択肢を除外する理由】
// 「アとイ」のような組み合わせ回答や、「一つ」のような個数回答は、
// それ単体では正誤を判定できる文章になっていないため、〇×問題にできません。
// 判定は「選択肢の文字数が短すぎないか」で機械的に行っています
// (組み合わせ・個数の選択肢はどちらも十分に短いため、これで実務上除外できます)。
import 'dart:convert';
import 'dart:io';

/// これより短い選択肢は「独立した正誤文ではない」とみなして除外する。
const _minStatementLength = 20;

/// 文章にひらがなが1文字も含まれない選択肢は、計算式や条文番号の羅列などであり、
/// 正誤を判定できる日本語の文章になっていないとみなして除外する
/// (例: "300,000円÷(365÷7×40÷12)" のような計算式の選択肢)。
final _hiraganaPattern = RegExp(r'[ぁ-ん]');

/// 問題文からこの問題の出題形式(正しいものを選ぶ/誤っているものを選ぶ)を判定する。
/// キーワードの直後に「は」が続く場合のみ、その問題の本当の設問文とみなす
/// (「誤っているものには×を付した場合の…正しいものはどれか」のような、
/// 本題とは関係のない箇所での「誤っているもの」の誤検出を避けるため)。
final _correctStemPattern = RegExp('正しいもの(の組合せ)?は');
final _incorrectStemPattern = RegExp('誤っているもの(の組合せ)?は');

enum _Polarity { seekCorrect, seekIncorrect, unknown }

_Polarity _detectPolarity(String questionText) {
  final correctMatches = _correctStemPattern.allMatches(questionText).toList();
  final incorrectMatches = _incorrectStemPattern.allMatches(questionText).toList();

  if (correctMatches.isEmpty && incorrectMatches.isEmpty) return _Polarity.unknown;
  if (correctMatches.isNotEmpty && incorrectMatches.isEmpty) return _Polarity.seekCorrect;
  if (correctMatches.isEmpty && incorrectMatches.isNotEmpty) return _Polarity.seekIncorrect;

  // 両方見つかった場合は、文章内でより後ろにある方(実際の設問文に近い方)を採用する。
  final lastCorrect = correctMatches.last.start;
  final lastIncorrect = incorrectMatches.last.start;
  return lastCorrect > lastIncorrect ? _Polarity.seekCorrect : _Polarity.seekIncorrect;
}

void main() {
  final questionsFile = File('assets/data/questions.json');
  final questions = jsonDecode(questionsFile.readAsStringSync()) as List<dynamic>;

  final quizItems = <Map<String, dynamic>>[];
  final skippedQuestions = <String>[]; // 出題形式が判定できず、問題ごと除外したもの
  final skippedChoices = <String>[]; // 短すぎて除外した個別の選択肢
  var fiveChoiceCount = 0;

  for (final raw in questions) {
    final q = raw as Map<String, dynamic>;
    if (q['questionType'] != 'fiveChoice') continue;
    fiveChoiceCount++;

    final questionId = q['id'] as String;
    final questionText = q['questionText'] as String;
    final correctAnswer = q['correctAnswer'] as String;
    final choices = (q['choices'] as List<dynamic>).cast<Map<String, dynamic>>();

    final polarity = _detectPolarity(questionText);
    if (polarity == _Polarity.unknown) {
      skippedQuestions.add('$questionId: 出題形式(正しいもの/誤っているもの)を判定できず');
      continue;
    }

    for (final choice in choices) {
      final choiceId = choice['id'] as String;
      final text = choice['text'] as String;
      if (text.length < _minStatementLength) {
        skippedChoices.add('${questionId}_$choiceId: 選択肢が短すぎるため除外(${text.length}文字): $text');
        continue;
      }
      if (!_hiraganaPattern.hasMatch(text)) {
        skippedChoices.add('${questionId}_$choiceId: ひらがなを含まない(計算式等)ため除外: $text');
        continue;
      }

      final isCorrectChoice = choiceId == correctAnswer;
      final isTrue = polarity == _Polarity.seekCorrect ? isCorrectChoice : !isCorrectChoice;

      quizItems.add({
        'id': '${questionId}_$choiceId',
        'sourceQuestionId': questionId,
        'subjectId': q['subjectId'],
        'topicId': q['topicId'],
        'sourceId': q['sourceId'],
        'year': q['year'],
        'statementText': text,
        'isTrue': isTrue,
        'explanation': q['explanation'],
        'learningPoint': q['learningPoint'],
        'commonTrap': q['commonTrap'],
        'legalBasis': q['legalBasis'],
        'importance': q['importance'],
      });
    }
  }

  final outFile = File('assets/data/quiz_items.json');
  const encoder = JsonEncoder.withIndent('  ');
  outFile.writeAsStringSync('${encoder.convert(quizItems)}\n');

  stdout.writeln('対象の5肢択一問題数: $fiveChoiceCount');
  stdout.writeln('生成した〇×クイズ数: ${quizItems.length}');
  stdout.writeln('');
  stdout.writeln('--- 出題形式が判定できず問題ごと除外(${skippedQuestions.length}件) ---');
  for (final line in skippedQuestions) {
    stdout.writeln(line);
  }
  stdout.writeln('');
  stdout.writeln('--- 短すぎて除外した選択肢(${skippedChoices.length}件) ---');
  for (final line in skippedChoices) {
    stdout.writeln(line);
  }
}

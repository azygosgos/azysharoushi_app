import 'package:flutter_test/flutter_test.dart';
import 'package:sharoushi_app/models/enums.dart';
import 'package:sharoushi_app/models/question.dart';

void main() {
  group('Question.toJson / fromJson', () {
    test('○×問題のデータが、JSON化して読み込み直しても壊れない', () {
      const question = Question(
        id: 'q001',
        subjectId: 'sub_roudoukijunhou',
        year: null,
        questionNumber: null,
        questionType: QuestionType.trueFalse,
        questionText: 'テスト問題文',
        correctAnswer: 'true',
        explanation: 'テスト解説',
        learningPoint: 'ポイント',
        commonTrap: 'ひっかけ',
        legalBasis: '労働基準法第35条',
        relatedArticleIds: ['art_35'],
        importance: Importance.s,
        topicId: 't_kyujitsu',
        sourceId: 'src_original',
      );

      final json = question.toJson();
      final restored = Question.fromJson(json);

      expect(restored.id, question.id);
      expect(restored.questionType, QuestionType.trueFalse);
      expect(restored.correctAnswer, 'true');
      expect(restored.relatedArticleIds, ['art_35']);
      expect(restored.importance, Importance.s);
    });

    test('5肢択一問題(選択肢あり)も正しく復元できる', () {
      const question = Question(
        id: 'q100',
        subjectId: 'sub_roudoukijunhou',
        questionType: QuestionType.fiveChoice,
        questionText: '5肢択一のテスト',
        choices: [
          Choice(id: 'A', text: '選択肢A'),
          Choice(id: 'B', text: '選択肢B'),
        ],
        correctAnswer: 'A',
        explanation: '解説',
      );

      final restored = Question.fromJson(question.toJson());

      expect(restored.choices.length, 2);
      expect(restored.choices.first.id, 'A');
      expect(restored.correctAnswer, 'A');
    });

    test('displayLabel: 年度と問題番号があれば「年 問n」、なければ「オリジナル問題」', () {
      const withYear = Question(
        id: 'q1',
        subjectId: 'sub_roudoukijunhou',
        year: 5,
        questionNumber: 3,
        questionType: QuestionType.trueFalse,
        questionText: '',
        correctAnswer: 'true',
        explanation: '',
      );
      const withoutYear = Question(
        id: 'q2',
        subjectId: 'sub_roudoukijunhou',
        questionType: QuestionType.trueFalse,
        questionText: '',
        correctAnswer: 'true',
        explanation: '',
      );

      expect(withYear.displayLabel, '5年 問3');
      expect(withoutYear.displayLabel, 'オリジナル問題');
    });
  });
}

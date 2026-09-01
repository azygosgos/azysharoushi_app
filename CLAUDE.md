# このプロジェクトについて (Claude Codeへの引き継ぎメモ)

このファイルは、Cowork(クラウド版のClaude)でのやり取りから、Claude Code(PC上で直接動くClaude)に開発を引き継ぐために書かれています。最初にこのファイルを読んで、状況を把握してから作業を始めてください。

## プロジェクト概要

- 社会保険労務士試験の学習用アプリ(個人利用専用)
- Flutter Web製のPWA(iPhoneのSafariで「ホーム画面に追加」してフルスクリーンで使える)
- クラウド/Firebase/ログイン機能は一切なし。データはすべて端末内のHiveローカルDBに保存
- 状態管理: Riverpod(コード生成なし。素のProvider/StateProvider/Provider.familyのみ)
- ユーザーはプログラミング初心者。コードは複雑にしすぎず、保守しやすさを最優先すること
- ユーザーとのやり取りは日本語で行うこと

## 現在の状況(2026年8月28日時点)

Phase 1(労働基準法のみのMVP)は完成し、動作確認済み:
- `flutter analyze` はクリーン(警告なし)
- `flutter test` は全11件パス
- iPhone SafariでのフルスクリーンPWAインストールを確認済み
- 問題データは `assets/data/questions.json` に24問(q001〜q024)
  - q001〜q017: オリジナルの○×問題(ダミー問題として最初に作成したもの)
  - q018〜q024: 令和7年度(第57回)社労士試験・労働基準法及び労働安全衛生法の択一式 問1〜問7(公式PDFから読み取った実際の過去問。5肢択一形式)
- `lib/services/data_loader_service.dart` の `currentDataVersion` は現在 `2`

## 進行中のタスク: 過去問データの追加

ユーザーが大量の過去問PDF(問題冊子+正答PDF、複数年度分)を集めました。これを `reference/past_exams/` フォルダに置いてもらう想定です(なければ作成済みなので、そこにPDFを入れてもらってください)。

このフォルダの中身を確認し、年度ごとに以下の手順で `assets/data/questions.json` に問題を追加していってください(令和7年度で確立した手順と同じです):

1. 該当年度の「択一式試験問題」PDFと「正答」PDFを読む
2. 各問題について、問題文・選択肢を(公式PDFの内容に基づいて)書き起こす。ただし市販テキストの丸写しは絶対にしないこと。解説(`explanation`)・学習ポイント(`learningPoint`)・間違えやすい点(`commonTrap`)は必ずオリジナルで作成すること(著作権への配慮)
3. `Question` モデル(`lib/models/question.dart`)の形式に沿ったJSONオブジェクトを作成する。フィールド: `id`(例: q025など、既存と重複しない連番)、`subjectId`、`year`、`questionNumber`、`questionType`(`fiveChoice`か`trueFalse`)、`questionText`、`choices`(fiveChoiceの場合はid:A〜E)、`correctAnswer`、`explanation`、`learningPoint`、`commonTrap`、`legalBasis`、`relatedArticleIds`、`importance`(`s`/`a`/`b`/`c`)、`topicId`、`sourceId`
4. 必要に応じて `assets/data/topics.json` に新しいトピックを追加する(既存idと重複しないこと)
5. `assets/data/sources.json` に、その年度の出典(公式サイトのPDF)を新しいsourceとして追加する(例: `src_r6_exam` など)
6. 追加後、必ずPythonなどでJSONの妥当性と整合性を検証する: 全体が正しいJSONであること、fiveChoiceの選択肢idが A,B,C,D,E で揃っていること、`correctAnswer` が選択肢の中に実在すること、`topicId`/`sourceId` が topics.json/sources.json に実在すること
7. 検証がすべて通ったら、`lib/services/data_loader_service.dart` の `currentDataVersion` を1つ増やす(**これを忘れると、既にインストール済みの端末に新しい問題が反映されません**)
8. ユーザーに、何年度の何問を追加したか、正解と出典を明記して報告する

## 進め方の方針

- ユーザーは1年ずつ確認しながら進めることも、まとめて進めることも可能。最初にどちらが良いか聞いてよい
- 大量に追加する場合も、1年度分ごとに区切ってJSONの妥当性検証を行うこと(まとめて最後に1回だけ検証、は避ける)
- 出典は必ず公式サイト(社会保険労務士試験オフィシャルサイト等)のPDFに基づくこと。ネット上の非公式な解答速報サイトのみを根拠にしないこと(過去に公式PDFと非公式サイトで解答が食い違った実例があったため)

## Phase 2 (今回のタスクではなく、将来的な拡張として合意済みだが未着手)

- 法律・条文ブラウジング画面
- 苦手問題(弱点)画面・アルゴリズム
- 復習メモ一覧・検索画面
- 学習履歴の集計画面
- バックアップ機能のUI組み込み(`lib/services/backup_service.dart` は実装済みだがUI未接続)
- 労働基準法以外の科目の追加

## 開発環境に関する注意

- ユーザーのPCはWindows。プロジェクトパスは `C:\Users\pinec\development\sharoushi_app`
- Python未インストール。ローカルサーバーが必要な場合はDart製の `dhttpd` を使う(`dart pub global activate dhttpd` → `dart pub global run dhttpd --path build\web --port 8000 --host 0.0.0.0`)
- 依存パッケージ: hive_ce / hive_ce_flutter(コード生成なしで `Map<String,dynamic>` を直接保存する使い方)

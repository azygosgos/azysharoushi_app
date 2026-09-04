# Cloudflare Workerのデプロイ手順(ユーザー作業)

このフォルダの `backup-worker.js` を、無料のCloudflare Workersにデプロイする手順です。
ログインが必要なため、この作業はユーザー自身がブラウザで行ってください。

1. https://dash.cloudflare.com/sign-up でアカウントを作成する(クレジットカード不要)
2. ダッシュボード左メニューの「Workers & Pages」→「Create」→「Create Worker」を選び、
   名前を付けて(例: `sharoushi-backup`)作成する
3. 作成後に開くコードエディタの中身をすべて削除し、`backup-worker.js` の内容を
   コピー&ペーストして、「Save and Deploy」(保存してデプロイ)を押す
4. ダッシュボード左メニューの「Workers & Pages」→「KV」→「Create a namespace」を選び、
   名前を付けて(例: `SHAROUSHI_BACKUP`)作成する
5. 手順2で作ったWorkerのページに戻り、「設定(Settings)」→「変数(Variables)」→
   「KV Namespace Bindings」で「Add binding」を押し、
   - Variable name: `BACKUP_KV`
   - KV namespace: 手順4で作ったもの
   を設定して保存する
6. Workerの概要ページに表示されているURL(`https://<worker名>.<何か>.workers.dev` の形)
   をコピーして、Claude Codeに伝える

以上が完了したら、Claude側でこのURLをアプリに設定してビルド・デプロイします。

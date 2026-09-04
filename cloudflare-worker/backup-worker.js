// Cloudflare Workersにデプロイするための、バックアップ中継スクリプト。
//
// 役割: 合言葉のSHA-256ハッシュ値をキーとして、学習データのJSONをKVに
// 保存(PUT)・取得(GET)するだけの単純な中継。合言葉自体はサーバーに送らない。
//
// デプロイ手順は README_DEPLOY.md を参照。
// KV Namespaceのバインディング変数名は "BACKUP_KV" にすること。

const MAX_BODY_BYTES = 1_000_000; // 1MB
const TTL_SECONDS = 60 * 60 * 24 * 180; // 180日
const KEY_PATTERN = /^[a-f0-9]{64}$/;

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, PUT, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    const key = url.searchParams.get('key');
    if (!key || !KEY_PATTERN.test(key)) {
      return new Response('invalid key', { status: 400, headers: CORS_HEADERS });
    }

    if (request.method === 'PUT') {
      const body = await request.text();
      if (body.length > MAX_BODY_BYTES) {
        return new Response('too large', { status: 413, headers: CORS_HEADERS });
      }
      await env.BACKUP_KV.put(key, body, { expirationTtl: TTL_SECONDS });
      return new Response('ok', { headers: CORS_HEADERS });
    }

    if (request.method === 'GET') {
      const value = await env.BACKUP_KV.get(key);
      if (value === null) {
        return new Response('not found', { status: 404, headers: CORS_HEADERS });
      }
      return new Response(value, {
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      });
    }

    return new Response('method not allowed', { status: 405, headers: CORS_HEADERS });
  },
};

// Cloudflare Worker for the NPTEL OCaml course quiz analytics.
//
// Five routes, all CORS-permissive (the lecture pages are served
// from a different origin: GitHub Pages):
//
//   POST /quiz             body: { reader_uuid, quiz_id, page, kind,
//                                  selected?, passed?, correct, commit_sha }
//                          Inserts one row into quiz_response.
//
//   GET  /quiz/agg         Aggregated stats per quiz_id (count, accuracy).
//                          Public, used by the dashboard page.
//
//   GET  /quiz/agg/readers Distinct reader_uuid count plus total response
//                          count. Public, used by the dashboard. Split
//                          from /quiz/agg so the heavier DISTINCT scan
//                          does not slow the per-quiz query.
//
//   POST /quiz/export      body: { reader_uuid }
//                          DPDPA right-to-access: return every row
//                          tied to the given UUID as JSON. The reader
//                          UUID is a secret the requester already has
//                          locally; no auth required.
//
//   POST /quiz/forget      body: { reader_uuid }
//                          DPDPA right-to-erasure: scrub all rows
//                          belonging to the given UUID.

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Max-Age': '86400',
};

const JSON_HEADERS = { ...CORS, 'Content-Type': 'application/json' };

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS });
    }

    const url = new URL(request.url);

    try {
      if (url.pathname === '/quiz' && request.method === 'POST') {
        return await handleQuizPost(request, env);
      }
      if (url.pathname === '/quiz/agg' && request.method === 'GET') {
        return await handleQuizAgg(env);
      }
      if (url.pathname === '/quiz/agg/readers' && request.method === 'GET') {
        return await handleQuizAggReaders(env);
      }
      if (url.pathname === '/quiz/export' && request.method === 'POST') {
        return await handleQuizExport(request, env);
      }
      if (url.pathname === '/quiz/forget' && request.method === 'POST') {
        return await handleQuizForget(request, env);
      }
      if (url.pathname === '/' || url.pathname === '/healthz') {
        // Tiny status endpoint so curl-from-CI smoke checks work.
        return new Response('nptel-quiz ok\n', { status: 200, headers: CORS });
      }
      return new Response('Not found', { status: 404, headers: CORS });
    } catch (e) {
      return new Response('Error: ' + (e?.message ?? String(e)), {
        status: 500,
        headers: CORS,
      });
    }
  },
};

// Defend against pathological input by capping every string field.
const cap = (s, n) => String(s ?? '').slice(0, n);
const boolToInt = (v) => (typeof v === 'boolean' ? (v ? 1 : 0) : null);

async function handleQuizPost(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return new Response('Bad JSON', { status: 400, headers: CORS });
  }

  const { reader_uuid, quiz_id, page, kind, selected, passed, attempts,
          correct, commit_sha } = body || {};

  if (!reader_uuid || !quiz_id || !page || !kind) {
    return new Response('Missing required fields', {
      status: 400, headers: CORS,
    });
  }
  if (kind !== 'mcq' && kind !== 'code') {
    return new Response('Bad kind', { status: 400, headers: CORS });
  }

  const reader = cap(reader_uuid, 64);
  const qid    = cap(quiz_id, 256);
  const pg     = cap(page, 256);
  const sel    = (kind === 'mcq' && Number.isInteger(selected)) ? selected : null;
  const pass   = (kind === 'code') ? boolToInt(passed) : null;
  const att    = Number.isInteger(attempts) ? attempts : 1;
  const corr   = boolToInt(correct);
  const sha    = cap(commit_sha, 64);
  const ts     = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO quiz_response
       (reader_uuid, quiz_id, page, kind, selected, passed, attempts, correct, commit_sha, ts)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  ).bind(reader, qid, pg, kind, sel, pass, att, corr, sha, ts).run();

  return new Response('OK', { status: 200, headers: CORS });
}

async function handleQuizAgg(env) {
  // Per-quiz aggregate: total responses, accuracy, plus per-option
  // breakdown for MCQ (helps spot the most popular distractor).
  const per_quiz = await env.DB.prepare(
    `SELECT quiz_id, kind,
            COUNT(*)                          AS attempts_total,
            SUM(COALESCE(correct, 0))         AS correct_total,
            AVG(COALESCE(correct, 0) * 1.0)   AS accuracy
       FROM quiz_response
      GROUP BY quiz_id, kind
      ORDER BY quiz_id`
  ).all();

  const mcq_options = await env.DB.prepare(
    `SELECT quiz_id, selected, COUNT(*) AS picks
       FROM quiz_response
      WHERE kind = 'mcq' AND selected IS NOT NULL
      GROUP BY quiz_id, selected
      ORDER BY quiz_id, selected`
  ).all();

  return new Response(JSON.stringify({
    per_quiz:    per_quiz.results,
    mcq_options: mcq_options.results,
  }), { status: 200, headers: JSON_HEADERS });
}

async function handleQuizAggReaders(env) {
  // Two scalars: count of distinct reader UUIDs, and the total
  // response count. The dashboard uses both for the headline cards.
  const row = await env.DB.prepare(
    `SELECT COUNT(DISTINCT reader_uuid) AS readers,
            COUNT(*)                    AS responses
       FROM quiz_response`
  ).first();

  return new Response(JSON.stringify({
    readers:   row?.readers   ?? 0,
    responses: row?.responses ?? 0,
  }), { status: 200, headers: JSON_HEADERS });
}

async function handleQuizExport(request, env) {
  // DPDPA right-to-access. Returns every row for the given UUID
  // as JSON. The requester must supply the UUID, which they have
  // in their browser's localStorage; no auth flow needed because
  // the UUID is itself the credential.
  let body;
  try { body = await request.json(); }
  catch { return new Response('Bad JSON', { status: 400, headers: CORS }); }

  const { reader_uuid } = body || {};
  if (!reader_uuid) {
    return new Response('Missing reader_uuid', { status: 400, headers: CORS });
  }
  const r = await env.DB.prepare(
    `SELECT quiz_id, page, kind, selected, passed, attempts,
            correct, commit_sha, ts
       FROM quiz_response
      WHERE reader_uuid = ?
      ORDER BY ts ASC`
  ).bind(cap(reader_uuid, 64)).all();

  return new Response(JSON.stringify({
    reader_uuid: cap(reader_uuid, 64),
    rows: r.results,
    count: r.results.length,
  }), { status: 200, headers: JSON_HEADERS });
}

async function handleQuizForget(request, env) {
  let body;
  try { body = await request.json(); }
  catch { return new Response('Bad JSON', { status: 400, headers: CORS }); }

  const { reader_uuid } = body || {};
  if (!reader_uuid) {
    return new Response('Missing reader_uuid', { status: 400, headers: CORS });
  }
  const r = await env.DB.prepare(
    'DELETE FROM quiz_response WHERE reader_uuid = ?'
  ).bind(cap(reader_uuid, 64)).run();

  return new Response(JSON.stringify({
    deleted: r?.meta?.changes ?? 0,
  }), { status: 200, headers: JSON_HEADERS });
}

-- Initial schema for the nptel-quiz D1 database.
--
-- One row per quiz response. The reader is identified by an
-- anonymous UUID minted client-side and stored in localStorage; no
-- PII is collected. The commit_sha lets us correlate responses with
-- a specific version of the lecture source, which is required for
-- TRPL-style before/after intervention analysis.

CREATE TABLE IF NOT EXISTS quiz_response (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  reader_uuid  TEXT    NOT NULL,
  quiz_id      TEXT    NOT NULL,   -- e.g. "M02-L01-literals.html#q1"
  page         TEXT    NOT NULL,   -- pathname only
  kind         TEXT    NOT NULL,   -- 'mcq' or 'code'
  selected     INTEGER,            -- MCQ only: zero-based option index
  passed       INTEGER,            -- code only: 0/1
  attempts     INTEGER DEFAULT 1,  -- counter (currently always 1)
  correct      INTEGER,            -- 0/1; mirrors mcq-correct or code-passed
  commit_sha   TEXT,               -- lecture source commit at the time
  ts           TEXT    NOT NULL    -- ISO 8601 timestamp set server-side
);

CREATE INDEX IF NOT EXISTS idx_qr_reader ON quiz_response(reader_uuid);
CREATE INDEX IF NOT EXISTS idx_qr_quiz   ON quiz_response(quiz_id);
CREATE INDEX IF NOT EXISTS idx_qr_ts     ON quiz_response(ts);

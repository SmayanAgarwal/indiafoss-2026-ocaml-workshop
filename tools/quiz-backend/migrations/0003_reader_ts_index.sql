-- Composite index for the per-reader daily write cap added to
-- POST /quiz: the Worker runs
--   SELECT COUNT(*) FROM quiz_response
--    WHERE reader_uuid = ? AND ts >= ?
-- before every insert. With this index the count is a range scan
-- over (reader_uuid, ts) instead of a walk of the single-column
-- idx_qr_reader entries.

CREATE INDEX IF NOT EXISTS idx_qr_reader_ts
  ON quiz_response(reader_uuid, ts);

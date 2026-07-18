ALTER TABLE backups ADD COLUMN content_hash TEXT;
ALTER TABLE backups ADD COLUMN size_bytes BIGINT;
ALTER TABLE backups ADD COLUMN device_id TEXT;
ALTER TABLE backups ADD COLUMN content_encoding TEXT;

-- Backfill metadata for any pre-existing rows before enforcing NOT NULL.
-- Legacy rows were stored as plain (uncompressed) JSONB, so tag them
-- 'identity' explicitly - only rows written after this migration use
-- 'gzip'.
UPDATE backups SET
    content_hash = encode(digest(payload::text, 'sha256'), 'hex'),
    size_bytes = octet_length(payload::text),
    content_encoding = 'identity'
WHERE content_hash IS NULL;

ALTER TABLE backups ALTER COLUMN payload TYPE BYTEA USING convert_to(payload::text, 'UTF8');
ALTER TABLE backups ALTER COLUMN content_hash SET NOT NULL;
ALTER TABLE backups ALTER COLUMN size_bytes SET NOT NULL;
ALTER TABLE backups ALTER COLUMN content_encoding SET NOT NULL;
ALTER TABLE backups ALTER COLUMN content_encoding SET DEFAULT 'gzip';

CREATE UNIQUE INDEX ux_backups_user_hash ON backups(user_id, content_hash);

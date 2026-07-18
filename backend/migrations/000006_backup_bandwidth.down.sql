-- Only safe to run if no row has content_encoding = 'gzip' - this cast
-- assumes payload is UTF8 JSON text, which gzip-compressed rows are not.
DROP INDEX IF EXISTS ux_backups_user_hash;
ALTER TABLE backups ALTER COLUMN payload TYPE JSONB USING convert_from(payload, 'UTF8')::jsonb;
ALTER TABLE backups DROP COLUMN content_hash;
ALTER TABLE backups DROP COLUMN size_bytes;
ALTER TABLE backups DROP COLUMN device_id;
ALTER TABLE backups DROP COLUMN content_encoding;

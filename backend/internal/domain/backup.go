package domain

import "time"

// Backup is an immutable snapshot of a store's entire local database.
// Payload is stored/forwarded byte-for-byte rather than unmarshaled into a
// Go map, since the backend never needs to interpret individual field
// values — only validate top-level shape and persist the bytes verbatim.
// Payload is gzip-compressed on the wire and at rest whenever ContentEncoding
// is "gzip" (the only encoding new uploads use); ContentEncoding is
// "identity" only for rows written before compression support existed.
type Backup struct {
	ID              string
	UserID          string
	Payload         []byte
	ContentHash     string
	ContentEncoding string
	SizeBytes       int64
	DeviceID        string
	CreatedAt       time.Time
}

// BackupSummary is the lightweight listing shape (no payload) returned by
// GET /backups.
type BackupSummary struct {
	ID        string
	CreatedAt time.Time
	SizeBytes int64
	DeviceID  string
}

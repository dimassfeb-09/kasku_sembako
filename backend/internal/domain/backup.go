package domain

import (
	"encoding/json"
	"time"
)

// Backup is an immutable JSON snapshot of a store's entire local database.
// Payload is stored/forwarded byte-for-byte (json.RawMessage) rather than
// unmarshaled into a Go map, since the backend never needs to interpret
// individual field values — only validate top-level shape and persist the
// bytes verbatim. Unmarshaling into map[string]interface{} would silently
// risk precision loss on numeric fields (Go decodes JSON numbers as
// float64), which this opaque-snapshot design deliberately avoids.
type Backup struct {
	ID        string
	UserID    string
	Payload   json.RawMessage
	CreatedAt time.Time
}

// BackupSummary is the lightweight listing shape (no payload) returned by
// GET /backups.
type BackupSummary struct {
	ID        string
	CreatedAt time.Time
	SizeBytes int64
}

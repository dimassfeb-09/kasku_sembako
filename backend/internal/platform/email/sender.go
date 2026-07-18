package email

import (
	"bytes"
	"embed"
	"fmt"
	"log"
	"net/smtp"
	"text/template"
	"time"
)

//go:embed templates/otp.html
var templatesFS embed.FS

var otpTemplate *template.Template

func init() {
	otpTemplate = template.Must(template.ParseFS(templatesFS, "templates/otp.html"))
}

type Config struct {
	Host     string
	Port     int
	User     string
	Pass     string
	From     string
	FromName string
}

// IsConfigured returns true when SMTP credentials are present.
func (c Config) IsConfigured() bool {
	return c.Host != "" && c.User != "" && c.Pass != ""
}

// OTPData is the template data for the OTP email.
type OTPData struct {
	OTP        string
	ExpiryTime string
}

// SendOTP sends an OTP email via SMTP, or logs it when SMTP is unconfigured.
// Returns true when the email was actually sent (or logged), false on error.
func SendOTP(cfg Config, to, otpCode string, expiresAt time.Time) bool {
	loc, _ := time.LoadLocation("Asia/Jakarta")
	expiryLocal := expiresAt.In(loc)

	data := OTPData{
		OTP:        otpCode,
		ExpiryTime: expiryLocal.Format("15:04"),
	}

	if !cfg.IsConfigured() {
		log.Printf("[EMAIL] OTP for %s: %s (expires at %s) — SMTP not configured, skipping send", to, otpCode, expiresAt.Format(time.RFC3339))
		return true
	}

	body, err := renderHTML(data)
	if err != nil {
		log.Printf("[EMAIL] template error for %s: %v — falling back to plain text", to, err)
		body = fmt.Sprintf("Kode OTP Anda: %s\n\nBerlaku hingga: %s", otpCode, data.ExpiryTime)
	}

	subject := "Kode OTP KasirKu"
	from := fmt.Sprintf("%s <%s>", cfg.FromName, cfg.From)
	toAddr := fmt.Sprintf("<%s>", to)

	headers := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/html; charset=\"UTF-8\"\r\n\r\n", from, toAddr, subject)
	msg := []byte(headers + body)

	addr := fmt.Sprintf("%s:%d", cfg.Host, cfg.Port)
	auth := smtp.PlainAuth("", cfg.User, cfg.Pass, cfg.Host)

	if err := smtp.SendMail(addr, auth, cfg.From, []string{to}, msg); err != nil {
		log.Printf("[EMAIL] failed to send OTP to %s via %s: %v", to, addr, err)
		return false
	}

	log.Printf("[EMAIL] OTP sent to %s successfully", to)
	return true
}

func renderHTML(data OTPData) (string, error) {
	var buf bytes.Buffer
	if err := otpTemplate.Execute(&buf, data); err != nil {
		return "", err
	}
	return buf.String(), nil
}

package jwtutil

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var (
	ErrInvalidToken     = errors.New("invalid or expired token")
	ErrInvalidTokenScope = errors.New("invalid token scope")
)

type Claims struct {
	UserID string `json:"sub"`
	Email  string `json:"email"`
	Role   string `json:"role,omitempty"`
	Scope  string `json:"scope,omitempty"`
	jwt.RegisteredClaims
}

const (
	ScopeAuth         = "auth"
	ScopePasswordReset = "password_reset"
)

const ClaimsLocalsKey = "claims"

func Issue(secret string, userID, email, role string, ttl time.Duration) (string, error) {
	return issue(secret, userID, email, role, ScopeAuth, ttl)
}

func IssueResetToken(secret string, userID, email string, ttl time.Duration) (string, error) {
	return issue(secret, userID, email, "", ScopePasswordReset, ttl)
}

func issue(secret, userID, email, role, scope string, ttl time.Duration) (string, error) {
	now := time.Now()
	claims := Claims{
		UserID: userID,
		Email:  email,
		Role:   role,
		Scope:  scope,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(ttl)),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}

func Verify(secret string, tokenString string) (*Claims, error) {
	claims, err := parse(secret, tokenString)
	if err != nil {
		return nil, err
	}
	if claims.Scope != ScopeAuth {
		return nil, ErrInvalidTokenScope
	}
	return claims, nil
}

func VerifyResetToken(secret string, tokenString string) (*Claims, error) {
	claims, err := parse(secret, tokenString)
	if err != nil {
		return nil, err
	}
	if claims.Scope != ScopePasswordReset {
		return nil, ErrInvalidTokenScope
	}
	return claims, nil
}

func parse(secret string, tokenString string) (*Claims, error) {
	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return []byte(secret), nil
	})
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}
	return claims, nil
}

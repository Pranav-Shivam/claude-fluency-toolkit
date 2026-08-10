# Authentication checklist

- Session tokens are generated with a cryptographically secure random source, not a predictable or low-entropy method.
- Session cookies set `HttpOnly`, `Secure`, and an appropriate `SameSite` value.
- Sessions are invalidated server-side on logout, not just cleared client-side.
- Session tokens rotate on privilege change (e.g. after login, after password change, after role elevation).
- Passwords are hashed with a modern, slow algorithm (bcrypt, scrypt, Argon2) at an adequate work factor — never MD5/SHA-1/plain SHA-256 alone.
- Password-reset tokens expire quickly, are single-use, and are invalidated once a new password is set.
- Login attempts are rate-limited or lockout-protected against brute force and credential stuffing.
- MFA, where implemented, is enforced consistently — no legacy or alternate login path that bypasses it.
- JWTs (or equivalent) have their signature verified server-side on every request, with the algorithm pinned (not attacker-selectable) and `exp` checked.
- Refresh tokens are rotated on use and revocable server-side; a stolen refresh token doesn't grant indefinite access.
- OAuth/OIDC/SAML integrations validate `state`/`nonce` parameters to prevent CSRF and replay.
- No debug, test, or "impersonate user" auth path is reachable outside a clearly gated development environment.

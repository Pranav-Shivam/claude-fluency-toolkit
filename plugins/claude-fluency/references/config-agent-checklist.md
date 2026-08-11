# Configuration checklist

- CORS does not allow `Access-Control-Allow-Origin: *` together with `Access-Control-Allow-Credentials: true`.
- CORS allowed origins are an explicit allowlist, not a regex broad enough to match attacker-controlled domains.
- `Content-Security-Policy` is set and doesn't rely on `unsafe-inline`/`unsafe-eval` without justification.
- `Strict-Transport-Security` is set with a meaningful `max-age` on any HTTPS-served app.
- `X-Content-Type-Options: nosniff` is set.
- Clickjacking protection is present (`X-Frame-Options` or CSP `frame-ancestors`).
- Auth/authorization middleware is registered before the routes it's meant to protect, not after.
- Error handlers don't leak stack traces, internal file paths, or SQL in production responses.
- Debug/verbose modes are off by default in production config, and there's no fallback that silently enables them.
- Required environment variables are validated at startup — the app fails fast rather than running with an unset secret.
- No secret has a hardcoded fallback value used when its environment variable is absent.
- File upload handling enforces a size limit and a file-type allowlist, not just a client-side check.
- Rate limiting exists on public-facing endpoints that are expensive or sensitive (login, search, export).

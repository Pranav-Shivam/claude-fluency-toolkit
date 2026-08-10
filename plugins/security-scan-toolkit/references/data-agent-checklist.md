# Data exposure checklist

- No PII, password, token, or full request/response body is written to logs at any log level.
- Debug-level logging that includes sensitive payloads cannot be accidentally enabled in production.
- API responses use an explicit response schema/serializer, not a raw database row or ORM object dump.
- Error responses don't leak stack traces, SQL statements, or internal file paths to the client.
- Sensitive tokens/PII are not stored in `localStorage`/`sessionStorage` where any script on the page (including an XSS payload) can read them.
- Prefer `HttpOnly` cookies for session tokens over client-readable storage.
- Database queries fetch only the fields actually needed downstream, especially when the result crosses a trust boundary (API response, cache shared across users, third-party call).
- Analytics/monitoring/logging SaaS integrations don't receive sensitive fields unredacted.
- Cached data (Redis, CDN, in-memory) that includes sensitive fields has scoping that prevents one user's cached data being served to another.
- Export/download features (CSV, PDF, reports) don't include fields beyond what the requesting user is authorized to see.
- Webhooks and outbound integrations don't forward more of the internal object than the receiving system needs.

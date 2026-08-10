# Database security checklist

- All queries use parameterized statements or ORM bindings — no string concatenation or f-string interpolation of user input into a query.
- ORM/driver "raw query" escape hatches (`.raw()`, `.exec()`, `.execute()` with a manually built string) are individually checked for injection, not assumed safe because "we mostly use the ORM."
- NoSQL query objects built from user input are validated/sanitized against operator injection (e.g. a client-supplied `$where`/`$ne` reaching a MongoDB query).
- Database credentials are not hardcoded in connection strings or source files.
- Connections use TLS where the database and driver support it.
- The application's database user/role has only the privileges it actually needs — no blanket admin grant for a service that only reads and writes application tables.
- Read-only workloads (reporting, analytics) use a read-only credential, not the same read-write account as the main application.
- Multi-tenant queries consistently filter by tenant/organization ID — this is checked on every query path that touches tenant-scoped data, not just the obvious ones.
- Vector database endpoints require authentication and aren't reachable unauthenticated on the network.
- Vector database API keys are handled with the same care as any other credential — not hardcoded, not logged.
- Connection pool configuration doesn't silently share one over-privileged connection across unrelated request contexts.

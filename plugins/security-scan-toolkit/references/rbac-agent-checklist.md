# RBAC and access control checklist

- Every API route has an explicit, identifiable authorization check — no route relies on "nothing links to it" as its security model.
- Object-level authorization is checked in addition to authentication: an endpoint verifies the requesting user has access to *this specific record*, not just that they're logged in.
- Permission/role checks are enforced consistently across every entry point into the same logic — API route, background job, internal service call, GraphQL resolver — not just the most obvious one.
- Role/permission fields on user-editable objects are stripped or ignored server-side, not trusted from client-submitted data.
- Admin or privileged actions are gated server-side, not only hidden behind a client-side UI conditional.
- New routes/resources default to denied unless explicitly granted a permission, rather than being reachable by default.
- Role definitions and their granted permissions are defined in one place, not duplicated and potentially drifting across multiple checks.
- Bulk/list endpoints filter results by the requesting user's access scope, not just individual-record endpoints.
- Impersonation or "act as" features (if present) are themselves permission-gated and audit-logged.

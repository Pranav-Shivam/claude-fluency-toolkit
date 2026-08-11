# Crypto and TLS checklist

- No use of MD5 or SHA-1 for anything security-sensitive (password hashing, signatures, integrity checks).
- No use of DES/3DES or ECB block-cipher mode anywhere in the codebase.
- Encryption keys and IVs are not hardcoded or committed alongside the code that uses them.
- IVs/nonces are generated fresh per encryption operation for modes that require uniqueness (CBC, GCM) — never reused or static.
- Password hashing uses bcrypt/scrypt/Argon2, not a fast general-purpose hash.
- Tokens, session IDs, and reset codes are generated with a CSPRNG, not a language-default pseudo-random generator.
- JWT verification pins the expected algorithm and rejects `alg: none` and unexpected algorithm switches.
- HMAC secrets for signed tokens are long enough to resist brute force (not a short/guessable string).
- TLS certificate validation is never disabled or overridden in application HTTP clients (no `verify=False` or custom trust-everything validator).
- Minimum TLS version pinned in code (if any) is 1.2 or higher.
- If a live endpoint was reachable and checked with `sslyze`: no expired/self-signed certs in production, no deprecated protocol versions (SSLv3, TLS 1.0/1.1) enabled, no weak cipher suites offered.
- Key rotation has a defined path — there's a way to rotate a compromised key without a full redeploy-and-hope.

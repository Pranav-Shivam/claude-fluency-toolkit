# IaC and container security checklist

- Dockerfiles specify a `USER` directive and don't run the application as root in the final image.
- Base images are pinned to a specific version/digest, not `:latest` or another mutable tag.
- No secret is passed as a build-time `ARG` (visible in image layer history) — secrets are injected at runtime instead.
- Multi-stage builds don't leak dev tooling, build caches, or source secrets into the final production stage.
- `.dockerignore` excludes `.env`, `.git`, and other files that shouldn't be in the build context at all.
- CI/CD pipelines don't print secrets to logs, even accidentally via a debug/verbose flag.
- Pull-request-triggered CI workflows don't run with write-level credentials or execute untrusted code from a fork with access to repo secrets.
- Third-party CI actions/steps are pinned to a commit SHA, not a mutable version tag, where supply-chain risk matters.
- Container orchestration manifests don't run containers in privileged mode without a specific, justified reason.
- Containers don't share the host network or PID namespace unless explicitly required.
- Resource limits (CPU/memory) are set to prevent a single container from being a noisy-neighbor DoS vector.
- Secrets used by containers are mounted via a secrets-management mechanism, not plain environment variables in a manifest committed to source control.

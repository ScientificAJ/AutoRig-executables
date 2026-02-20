# AutoRig Executables v0.2.4

## Highlights

- Strict per-vertex skin-weight normalization with deterministic degenerate-row handling.
- Symmetry enforcement is now gated by mesh symmetry detection; asymmetric meshes are preserved.
- Stable local bone axis/roll metadata generation to improve IK-friendly orientation behavior.
- API runtime resilience:
  - non-blocking bounded job queue
  - deterministic topology/format/complexity mesh errors
  - environment-driven CORS allowlist/regex handling
- Blender add-on UX resilience:
  - non-blocking modal polling and cancellation support
  - dependency preflight checks and actionable guidance
  - vertex mapping mismatch guards before import
- Web client resilience:
  - primary `NEXT_PUBLIC_API_URL` and `NEXT_PUBLIC_WS_URL` support
  - timeout/backoff/cancel polling behavior
  - WebGL context-loss and disposal handling

## Included Artifacts

- `bin/autorig_cli-linux-x86_64`
- `plugins/autorig_blender-0.2.4.zip`
- `bin/setup.sh`
- `SHA256SUMS`

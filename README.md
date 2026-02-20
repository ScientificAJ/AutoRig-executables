# AutoRig Executables

Rebuilt artifacts for AutoRig `0.2.4`.

## Included Artifacts

- `bin/autorig_cli-linux-x86_64`
- `plugins/autorig_blender-0.2.4.zip`
- `bin/setup.sh`
- `SHA256SUMS`
- `RELEASE_METADATA.json`

## What's New In This Build

- Rig output stabilization:
  - strict per-vertex skin weight normalization
  - finite-value clamping and deterministic zero-weight recovery
- Symmetry handling:
  - mirrored constraints are applied only when mesh symmetry confidence is high
  - intentionally asymmetric meshes are no longer force-mirrored
- Mesh normalization:
  - adaptive scale normalization and optional up-axis auto inference in preprocessing
  - reversible metadata for transport and consumer safety
- API reliability improvements:
  - bounded async job queue with explicit timeout and queue-full behavior
  - deterministic mesh topology/format/complexity error IDs
  - environment-driven CORS allowlist/regex configuration
- Blender reliability improvements:
  - non-blocking modal polling with cancellation support
  - dependency preflight for `requests`/`numpy`
  - guarded vertex mapping mismatch handling
- Web reliability improvements:
  - `NEXT_PUBLIC_API_URL`/`NEXT_PUBLIC_WS_URL` endpoint support
  - robust polling timeout/backoff/cancel behavior
  - WebGL context-loss handling and cleanup

## Quick Start

```bash
chmod +x setup.sh
./setup.sh
```

Or run the CLI directly:

```bash
chmod +x bin/autorig_cli-linux-x86_64
./bin/autorig_cli-linux-x86_64 validate --help
```

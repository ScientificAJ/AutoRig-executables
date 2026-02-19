# AutoRig Executables

Rebuilt artifacts for AutoRig `0.2.1`.

## Included Artifacts

- `bin/autorig_cli-linux-x86_64`
- `plugins/autorig_blender-0.2.1.zip`
- `setup.sh`
- `SHA256SUMS`
- `RELEASE_METADATA.json`

## What’s New In This Build

- Large-scale contact pose library (index-first, lazy-loaded, schema-versioned)
- Contact constraints:
  - hand-in-pocket (marker-first with inferred fallback)
  - hand-on-hip
  - foot planted
  - cross-leg contact
  - knee-to-ground contact
- Deterministic pose solve pipeline with fallback chain:
  - requested pose -> nearest safe pose -> neutral safe fallback
- New CLI pose controls:
  - `--pose`
  - `--pose-side`
  - `--pose-intensity`
  - `--pose-damping`
  - `--pose-falloff`
  - `--pose-param`
  - `--pose-stack`
  - `--pose-batch-preload`
  - `--pose-mode`

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

# AutoRig Executables

Rebuilt artifacts for AutoRig `0.2.3`.

## Included Artifacts

- `bin/autorig_cli-linux-x86_64`
- `plugins/autorig_blender-0.2.3.zip`
- `setup.sh`
- `SHA256SUMS`
- `RELEASE_METADATA.json`

## What’s New In This Build

- Film facial eyelid color contract added across CLI/Web/Blender/API:
  - `options.film_extension.facial_plugin.appearance.eyelid_color`
- Field validation:
  - hex colors must be `#RRGGBB`
  - opacity must be finite and in `[0,1]`
  - color space is `srgb`
- API now returns deterministic validation errors:
  - `AUTORIG_EYELID_COLOR_INVALID`
- Runtime metadata emission:
  - `metadata.extensions.film.facial_plugin.appearance.eyelid_color`
- Existing pocket-anchor contract and confirmation gate behavior are preserved.

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

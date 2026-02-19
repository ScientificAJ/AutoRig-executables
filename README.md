# AutoRig Artifacts

Prebuilt AutoRig artifacts intended for end users and integrators.

Build:

- Version: `0.2.1`
- Build date (UTC): `2026-02-19`

Source code and developer documentation live in:

- `https://github.com/ScientificAJ/AutoRig`

## What’s Included

| Path | Description |
|------|-------------|
| `bin/autorig_cli-linux-x86_64` | Linux (x86_64) CLI binary (runs locally, no Python install required). |
| `bin/setup.sh` | Helper to start the local API server and (optionally) open the EXPERIMENTAL drawing UI. |
| `plugins/autorig_blender-0.2.1.zip` | Blender add-on zip (install in Blender Preferences). |
| `proposal/autorig_enterprise_proposal.pdf` | Proposal / deck PDF. |
| `BUILD_INFO.json` | Build provenance (source commit + artifact hashes). |
| `SHA256SUMS` | Integrity hashes for distributed artifacts. |
| `docs/` | Quickstart, Blender install, checksum verification. |

## Verify Integrity (Recommended)

```bash
sha256sum -c SHA256SUMS
```

## Quickstart: Local API Server

```bash
bash ./bin/setup.sh --host 127.0.0.1 --port 8000
```

Then open:

- `http://127.0.0.1:8000/docs`
- `http://127.0.0.1:8000/healthz`

## Quickstart: CLI (Local Rig Export)

OBJ input is supported out-of-the-box:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json
```

Notes:

- `.fbx/.glb` loading requires `trimesh` and is supported when running from source (not guaranteed in this binary).

## EXPERIMENTAL: Hair Rigging + Cloth Assist + Motion Presets

This release includes disabled-by-default helper rig layers:

- Hair helper chains: `hair_grp_*`
- Cloth assist chains: `cloth_grp_*`
- Motion preset library: 250 JSON presets (index-first + lazy-load)

Browse/search presets:

```bash
./bin/autorig_cli-linux-x86_64 presets search Wind_ --limit 10
./bin/autorig_cli-linux-x86_64 presets show Wind_001
```

Run with experimental helpers enabled:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json \
  --experimental-hair-rigging --experimental-cloth-assist \
  --preset Wind_001 --intensity 0.5 --vector "0,1,0"
```

## EXPERIMENTAL: Geometric Inference (Draw -> Recognize -> Correct)

Launch the EXPERIMENTAL drawing UI:

```bash
bash ./bin/setup.sh --geometric
```

This opens:

- `/experimental/geometric` (**EXPERIMENTAL**)

Compatibility guarantee:

- When EXPERIMENTAL mode is disabled (default), behavior is identical to the default ML mode.

## Blender Add-on

See `docs/BLENDER_INSTALL.md`.

## Documentation

- `docs/QUICKSTART.md`
- `docs/BLENDER_INSTALL.md`
- `docs/VERIFY_CHECKSUMS.md`

## Support

- Email: `support@astroclub.space`

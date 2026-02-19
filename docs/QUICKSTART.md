# Quickstart

## 1) Verify Integrity (Recommended)

```bash
sha256sum -c SHA256SUMS
```

## 2) Optional: Check Available Commands

```bash
./bin/autorig_cli-linux-x86_64 --help
```

If the binary is not executable:

```bash
chmod +x ./bin/autorig_cli-linux-x86_64
```

## 3) Start Local API Service

```bash
bash ./bin/setup.sh --host 127.0.0.1 --port 8000
```

If startup is slow on your machine/network, increase wait timeout:

```bash
bash ./bin/setup.sh --host 127.0.0.1 --port 8000 --wait-seconds 60
```

`setup.sh` automatically reuses a healthy running API or picks a fallback port if needed.

Then open:

- Swagger UI: `http://127.0.0.1:8000/docs`
- Health endpoint: `http://127.0.0.1:8000/healthz`

Stop the server with `Ctrl+C`.

## 4) Run CLI (Local Rig Export)

OBJ input is supported out-of-the-box:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json
```

## 5) EXPERIMENTAL: Geometric Inference (Optional)

This mode is disabled by default and is feature-flagged.

EXPERIMENTAL drawing UI (opens a browser window):

```bash
bash ./bin/setup.sh --geometric
```

If you only want the server (no auto-open):

```bash
bash ./bin/setup.sh --geometric --no-open
```

This opens:

- `/experimental/geometric` (**EXPERIMENTAL**)

## 6) EXPERIMENTAL: Hair + Cloth Assist + Motion Presets (Optional)

Browse/search the bundled motion preset library:

```bash
./bin/autorig_cli-linux-x86_64 presets search Wind_ --limit 10
./bin/autorig_cli-linux-x86_64 presets show Wind_001
```

Run with experimental helper rigs enabled:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json \
  --experimental-hair-rigging --experimental-cloth-assist \
  --preset Wind_001 --intensity 0.5 --vector "0,1,0"
```

## 7) EXPERIMENTAL: Film Extension (Optional)

Enable film-ready helper joints:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json \
  --film-extension
```

Enable the optional facial plugin:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json \
  --film-extension --film-facial-plugin --film-facial-mode auto
```

Facial placement modes:

- `offset`
- `surface_project`
- `landmark`
- `auto` (`landmark -> surface_project -> offset`)

Optional calibration override:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json \
  --film-extension --film-facial-plugin \
  --film-facial-mode landmark \
  --film-facial-calibration '{"offset_scale_x":1.05}'
```

Optional eyelid color appearance block:

```bash
./bin/autorig_cli-linux-x86_64 validate \
  --mesh model.obj --target blender --out output/model.rig.json \
  --film-extension --film-facial-plugin \
  --film-facial-eyelid-color-enabled \
  --film-facial-eyelid-left-upper "#6A4C4C" \
  --film-facial-eyelid-left-lower "#5A3F3F" \
  --film-facial-eyelid-right-upper "#6A4C4C" \
  --film-facial-eyelid-right-lower "#5A3F3F" \
  --film-facial-eyelid-opacity 0.65 \
  --film-facial-eyelid-color-space srgb
```

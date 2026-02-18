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

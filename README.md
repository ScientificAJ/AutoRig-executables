# AutoRig Executables

Executable-focused distribution for AutoRig.

## Included

- `autorig_cli-linux-x86_64` (Linux CLI executable)
- `setup.sh` (setup helper script)
- `autorig_blender-0.1.0.zip` (Blender add-on package)

## Run CLI

```bash
chmod +x ./autorig_cli-linux-x86_64
./autorig_cli-linux-x86_64 --help
```

## Run Web/API Interface

```bash
./autorig_cli-linux-x86_64 server --host 127.0.0.1 --port 8000
```

Then open:

- `http://127.0.0.1:8000/docs` (Swagger UI web interface)
- `http://127.0.0.1:8000/healthz`

## Notes

- No standalone project `.py` source files are committed at repo root.
- Blender plugin zip is the standard Blender add-on format and contains `.py` files internally.

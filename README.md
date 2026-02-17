# AutoRig Distribution

Professional distribution repository for AutoRig executable artifacts.

## Repository Layout

- `bin/autorig_cli-linux-x86_64` - Linux CLI binary
- `bin/setup.sh` - setup helper script
- `plugins/autorig_blender-0.1.0.zip` - Blender add-on package
- `proposal/autorig_enterprise_proposal.pdf` - business proposal deck
- `docs/` - usage, verification, and installation guides
- `SHA256SUMS` - integrity hashes for distributed artifacts

## Quick Start

```bash
chmod +x ./bin/autorig_cli-linux-x86_64
./bin/autorig_cli-linux-x86_64 --help
```

Run API server and open the web interface:

```bash
./bin/autorig_cli-linux-x86_64 server --host 127.0.0.1 --port 8000
```

Then visit:

- `http://127.0.0.1:8000/docs`
- `http://127.0.0.1:8000/healthz`

## Documentation

- `docs/QUICKSTART.md`
- `docs/BLENDER_INSTALL.md`
- `docs/VERIFY_CHECKSUMS.md`

## Support

- Email: `support@astroclub.space`


# Quickstart

## 1. Run setup

```bash
bash ./bin/setup.sh
```

## 2. Optional: check available commands

```bash
./bin/autorig_cli-linux-x86_64 --help
```

## 3. Start API service

```bash
bash ./bin/setup.sh --run --host 127.0.0.1 --port 8000
```

## 4. Open browser UI

- Swagger UI: `http://127.0.0.1:8000/docs`
- Health endpoint: `http://127.0.0.1:8000/healthz`

## 5. Stop service

Press `Ctrl+C` in the terminal running the server.

# Quickstart

## 1. Make binary executable

```bash
chmod +x ./bin/autorig_cli-linux-x86_64
```

## 2. Check available commands

```bash
./bin/autorig_cli-linux-x86_64 --help
```

## 3. Start API service

```bash
./bin/autorig_cli-linux-x86_64 server --host 127.0.0.1 --port 8000
```

## 4. Open browser UI

- Swagger UI: `http://127.0.0.1:8000/docs`
- Health endpoint: `http://127.0.0.1:8000/healthz`

## 5. Stop service

Press `Ctrl+C` in the terminal running the server.

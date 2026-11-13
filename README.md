# Hetzner Tools

Small helpers for Hetzner managed servers.

## Codex setup

```bash
curl -fsSLo /tmp/hetzner-codex-processes.sh https://raw.githubusercontent.com/aggrosoft/hetzner-tools/main/scripts/hetzner-codex-processes.sh
bash /tmp/hetzner-codex-processes.sh --setup
```

Installs Codex CLI if missing, installs the Codex extension when VS Code Remote-SSH is connected, and prints a short process-whitelist ticket. VS Code itself installs the server on first connection. Omit `--setup` for a read-only report.

# Hetzner Tools

Small helpers for Hetzner managed servers.

## Codex process report

Finds the VS Code Remote-SSH and Codex executables and prints a short support-ticket draft for process whitelisting.

```bash
curl -fsSLo /tmp/hetzner-codex-processes.sh https://raw.githubusercontent.com/aggrosoft/hetzner-tools/main/scripts/hetzner-codex-processes.sh
bash /tmp/hetzner-codex-processes.sh
```

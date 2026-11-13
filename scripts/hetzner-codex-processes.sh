#!/usr/bin/env bash
# Read-only report for Hetzner Managed Server process whitelist requests.
set -u

report_user="$(id -un)"
report_home="${CODEX_REPORT_HOME:-${HOME:-}}"
report_host="$(hostname -f 2>/dev/null || hostname 2>/dev/null || printf 'unbekannt')"

if [[ -z "$report_home" ]]; then
  printf 'Fehler: Home-Verzeichnis konnte nicht ermittelt werden.\n' >&2
  exit 1
fi

# The separately installed CLI may be a symlink. Its real executable can
# differ from the path used to start it.
report_cli="$(type -P codex 2>/dev/null || true)"
report_cli_real=""
if [[ -n "$report_cli" ]] && command -v readlink >/dev/null 2>&1; then
  report_cli_real="$(readlink -f -- "$report_cli" 2>/dev/null || true)"
fi

report_vscode="$report_home/.vscode-server"
report_ext=""
report_node=""
report_node_old=""
report_code=""
report_wrapper=""

if [[ -d "$report_vscode/extensions" ]]; then
  report_ext="$(find "$report_vscode/extensions" -type f \
    -path '*/openai.chatgpt-*/bin/*/codex' -print 2>/dev/null | sort)"
fi

if [[ -d "$report_vscode/cli/servers" ]]; then
  report_node="$(find "$report_vscode/cli/servers" -type f \
    -path '*/server/node' -print 2>/dev/null | sort)"
  report_wrapper="$(find "$report_vscode/cli/servers" -type f \
    -path '*/server/bin/code-server' -print 2>/dev/null | sort)"
fi

if [[ -d "$report_vscode/bin" ]]; then
  report_node_old="$(find "$report_vscode/bin" -mindepth 2 -maxdepth 2 \
    -type f -name node -print 2>/dev/null | sort)"
fi

if [[ -d "$report_vscode" ]]; then
  report_code="$(find "$report_vscode" -maxdepth 1 -type f \
    -name 'code-*' -print 2>/dev/null | sort)"
fi

print_detected() {
  local name="$1" paths="$2"
  if [[ -n "$paths" ]]; then
    printf '%s:\n%s\n' "$name" "$paths"
  else
    printf '%s: nicht gefunden\n' "$name"
  fi
}

printf '=== Hetzner-Prozessfreigabe: Tickettext ===\n'
printf 'Betreff: Prozessfreigabe VS Code Remote-SSH / OpenAI Codex\n\n'
printf 'Guten Tag,\n\n'
printf 'bitte richten Sie für den SSH-Benutzer %s auf %s\n' "$report_user" "$report_host"
printf '(Home: %s) eine dauerhafte Prozessfreigabe ein:\n\n' "$report_home"

if [[ -n "$report_cli" ]]; then
  printf '%s\n' "- $report_cli"
  if [[ -n "$report_cli_real" && "$report_cli_real" != "$report_cli" ]]; then
    printf '%s\n' "  (reales Ziel: $report_cli_real)"
  fi
fi

if [[ -n "$report_ext" ]]; then
  printf '%s\n' "- $report_vscode/extensions/openai.chatgpt-*/bin/*/codex (Codex app-server)"
fi

if [[ -n "$report_node" ]]; then
  printf '%s\n' "- $report_vscode/cli/servers/Stable-*/server/node (VS Code Server/ExtensionHost)"
  if [[ -n "$report_wrapper" ]]; then
    printf '%s\n' "- $report_vscode/cli/servers/Stable-*/server/bin/code-server (Startskript)"
  fi
fi

if [[ -n "$report_node_old" ]]; then
  printf '%s\n' "- $report_vscode/bin/*/node (ältere VS-Code-Installation)"
fi

if [[ -n "$report_code" ]]; then
  printf '%s\n' "- $report_vscode/code-* (VS Code Remote-Launcher)"
fi

printf '\nBitte die Freigaben versionsunabhängig einrichten (regelmäßige Updates)\n'
printf 'und die erforderlichen Laufzeit-/Speicherlimits berücksichtigen.\n'
printf 'Bitte auch prüfen, ob die Prozesswache SIGKILL-Abbrüche der\n'
printf 'Codex-Erweiterung verursacht. Vielen Dank!\n\n'

printf '=== Tatsächlich installierte Dateien (zur Kontrolle) ===\n'
print_detected 'Codex CLI' "$report_cli"
if [[ -n "$report_cli_real" && "$report_cli_real" != "$report_cli" ]]; then
  printf 'Reales CLI-Ziel: %s\n' "$report_cli_real"
fi
print_detected 'Codex VS-Code-Erweiterung' "$report_ext"
print_detected 'VS Code Node.js' "$report_node"
print_detected 'VS Code Node.js (alt)' "$report_node_old"
print_detected 'VS Code Launcher' "$report_code"
print_detected 'VS Code Startskript' "$report_wrapper"

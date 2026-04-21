#!/usr/bin/env bash
# Spawn a named Claude --remote-control session in a new Terminal window
# Usage: spawn.sh <name> [workdir] [model]

set -e

REGISTRY=~/.claude/session-registry.json

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_reg_write() {
  local name=$1 window_id=$2 pid=$3 workdir=$4 model=$5
  _reg_init
  local tmp=$(mktemp)
  jq --arg n "$name" --argjson w "$window_id" --argjson p "$pid" \
     --arg d "$workdir" --arg m "$model" --arg t "$(date -u +%FT%TZ)" \
     '.[$n] = {window_id: $w, pid: $p, workdir: $d, model: $m, started: $t}' \
     "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local name=$1 workdir=${2:-$HOME} model=${3:-haiku}

  if [[ -z "$name" ]]; then
    echo "Error: name is required"
    echo "Usage: spawn.sh <name> [workdir] [model]"
    echo "Example: spawn.sh Worker1 ~/project haiku"
    return 1
  fi

  # Spawn session in new Terminal window via AppleScript (always quote args)
  local window_id
  window_id=$(osascript -e "
    tell application \"Terminal\"
      activate
      do script \"cd '$workdir' && claude --remote-control -n '$name' --model '$model'\"
    end tell" | grep -oE '[0-9]+$')

  if [[ -z "$window_id" ]]; then
    echo "Error: failed to spawn Terminal window"
    return 1
  fi

  sleep 5  # wait for session to initialize

  # Capture PID from process list
  local manager_pid
  manager_pid=$(pgrep -f "claude --remote-control" | head -1)
  local pid
  pid=$(pgrep -f "claude --remote-control" | grep -v "^$manager_pid$" | tail -1)

  if [[ -z "$pid" ]]; then
    echo "Error: could not find PID for $name"
    return 1
  fi

  _reg_write "$name" "$window_id" "$pid" "$workdir" "$model"
  echo "Spawned '$name' — window=$window_id pid=$pid model=$model"
}

main "$@"

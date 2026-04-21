#!/usr/bin/env bash
# Gracefully shut down a named session

set -e

REGISTRY=~/.claude/session-registry.json

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_reg_get() {
  local name=$1 field=$2
  jq -r --arg n "$name" --arg f "$field" '.[$n][$f] // empty' "$REGISTRY"
}

_reg_delete() {
  local name=$1
  local tmp=$(mktemp)
  jq --arg n "$name" 'del(.[$n])' "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local name=$1

  if [[ -z "$name" ]]; then
    echo "Error: name is required"
    echo "Usage: shutdown.sh <name>"
    echo "Example: shutdown.sh Worker1"
    return 1
  fi

  _reg_init

  local window_id pid
  window_id=$(_reg_get "$name" window_id)
  pid=$(_reg_get "$name" pid)

  if [[ -z "$window_id" || -z "$pid" ]]; then
    echo "Error: '$name' not found in registry"
    return 1
  fi

  # Verify PID is still a claude process
  if ! ps -p "$pid" -o comm= 2>/dev/null | grep -q claude; then
    echo "Warning: PID $pid for '$name' is no longer a claude process — cleaning registry only"
    _reg_delete "$name"
    return 0
  fi

  echo "Shutting down '$name' (window=$window_id pid=$pid)..."

  # Send /exit to the session
  osascript -e "tell application \"Terminal\" to do script \"/exit\" in tab 1 of window id $window_id" > /dev/null 2>&1

  # Wait for process to exit (up to 10s)
  local i=0
  while kill -0 "$pid" 2>/dev/null && (( i < 50 )); do
    sleep 0.2; (( i++ ))
  done

  if kill -0 "$pid" 2>/dev/null; then
    echo "Warning: process did not exit cleanly — sending SIGINT"
    kill -INT "$pid"
    sleep 1
  fi

  # Close the window
  osascript -e "tell application \"Terminal\" to close window id $window_id" 2>/dev/null

  _reg_delete "$name"
  echo "Done — '$name' shut down"
}

main "$@"

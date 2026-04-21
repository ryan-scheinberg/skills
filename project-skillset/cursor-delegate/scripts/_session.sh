#!/usr/bin/env bash
# Shared helper: resolve the current Claude session ID by walking the
# process tree up to the ancestor `claude` process and reading its
# --resume <uuid> arg. Falls back to the claude process PID.

_claude_session_id() {
  local pid=$$
  local guard=0
  while [[ "$pid" != "1" && -n "$pid" && $guard -lt 20 ]]; do
    local cmd
    cmd=$(ps -o command= -p "$pid" 2>/dev/null || true)
    if [[ "$cmd" =~ (^|/)claude([[:space:]]|$) ]]; then
      local uuid
      uuid=$(echo "$cmd" | grep -oE -- '--resume [a-f0-9-]+' | awk '{print $2}')
      if [[ -n "$uuid" ]]; then
        echo "$uuid"
        return 0
      fi
      echo "pid-$pid"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    guard=$((guard+1))
  done
  echo "unknown"
}

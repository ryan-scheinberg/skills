#!/usr/bin/env bash
# Find the ancestor `claude` process PID. Serves as a stable
# per-session identifier across bash tool calls, where $PPID
# points to an ephemeral wrapper shell rather than Claude itself.

_claude_session_id() {
  local pid=$$
  local guard=0
  while [[ "$pid" != "1" && -n "$pid" && $guard -lt 20 ]]; do
    local cmd
    cmd=$(ps -o command= -p "$pid" 2>/dev/null || true)
    if [[ "$cmd" =~ (^|/)claude([[:space:]]|$) ]]; then
      echo "$pid"
      return 0
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    guard=$((guard+1))
  done
  echo "$PPID"
}

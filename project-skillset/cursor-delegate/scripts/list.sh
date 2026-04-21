#!/usr/bin/env bash
# List cursor jobs for current Claude session
# Usage: list.sh

set -e

REGISTRY=~/.claude/cursor-registry.json

main() {
  if [[ ! -f "$REGISTRY" ]] || [[ $(jq 'length' "$REGISTRY" 2>/dev/null || echo 0) -eq 0 ]]; then
    echo "No jobs"
    return 0
  fi

  # Refresh status: mark dead processes as done
  local tmp
  tmp=$(mktemp)
  cp "$REGISTRY" "$tmp"
  while IFS= read -r job_id; do
    local pid status
    pid=$(jq -r --arg j "$job_id" '.[$j].pid' "$tmp")
    status=$(jq -r --arg j "$job_id" '.[$j].status' "$tmp")
    if [[ "$status" == "running" ]] && ! kill -0 "$pid" 2>/dev/null; then
      local tmp2
      tmp2=$(mktemp)
      jq --arg j "$job_id" '.[$j].status = "done"' "$tmp" > "$tmp2" && mv "$tmp2" "$tmp"
    fi
  done < <(jq -r 'keys[]' "$tmp")
  mv "$tmp" "$REGISTRY"

  # Filter to current Claude session
  local count
  count=$(jq --argjson p "$PPID" '[.[] | select(.claude_pid == $p)] | length' "$REGISTRY")
  if [[ "$count" -eq 0 ]]; then
    echo "No jobs for this Claude session"
    return 0
  fi

  echo "Jobs for this Claude session:"
  jq -r --argjson p "$PPID" \
     'to_entries[] | select(.value.claude_pid == $p) | "  \(.key)\tstatus=\(.value.status) pid=\(.value.pid) workspace=\(.value.workspace)"' \
     "$REGISTRY"
}

main "$@"

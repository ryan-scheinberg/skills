#!/usr/bin/env bash
# Spawn Composer 2 on a task in background. Returns job_id.
# Usage: delegate.sh <task> [workspace]

set -e

REGISTRY=~/.claude/cursor-registry.json
MAX_PER_SESSION=2

_reg_init() {
  [[ -f "$REGISTRY" ]] || echo '{}' > "$REGISTRY"
}

_count_active() {
  local claude_pid=$1
  jq --argjson p "$claude_pid" \
     '[.[] | select(.claude_pid == $p and .status == "running")] | length' \
     "$REGISTRY"
}

_reg_write() {
  local job_id=$1 claude_pid=$2 pid=$3 workspace=$4 task=$5 log_file=$6
  local tmp=$(mktemp)
  jq --arg j "$job_id" --argjson cp "$claude_pid" --argjson p "$pid" \
     --arg w "$workspace" --arg t "$task" --arg l "$log_file" \
     --arg ts "$(date -u +%FT%TZ)" \
     '.[$j] = {claude_pid: $cp, pid: $p, workspace: $w, task: $t, log_file: $l, started: $ts, status: "running"}' \
     "$REGISTRY" > "$tmp" && mv "$tmp" "$REGISTRY"
}

main() {
  local task=$1 workspace=${2:-.}

  if [[ -z "$task" ]]; then
    echo "Error: task is required" >&2
    echo "Usage: delegate.sh <task> [workspace]" >&2
    return 1
  fi

  _reg_init

  local active
  active=$(_count_active "$PPID")
  if (( active >= MAX_PER_SESSION )); then
    echo "Error: $active active jobs (max $MAX_PER_SESSION per Claude session)" >&2
    echo "Check: bash scripts/list.sh" >&2
    return 1
  fi

  local job_id="cursor-$(date +%s)-$$"
  local log_file="/tmp/cursor-delegate-${job_id}.log"

  nohup cursor agent \
    --print \
    --output-format json \
    --model composer-2 \
    --workspace "$workspace" \
    --trust \
    "$task" > "$log_file" 2>&1 &
  local pid=$!
  disown

  _reg_write "$job_id" "$PPID" "$pid" "$workspace" "$task" "$log_file"
  echo "Spawned $job_id (pid=$pid)"
  echo "Check: bash scripts/status.sh $job_id"
}

main "$@"

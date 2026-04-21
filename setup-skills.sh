#!/usr/bin/env bash
# Install skills as flat symlinks under ~/.claude/skills and ~/.cursor/skills.
# Claude Code CLI and Cursor read from these paths.
# Re-run after adding, moving, or renaming skills.

set -e

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LINK_ROOTS=("$HOME/.claude/skills" "$HOME/.cursor/skills")

main() {
  local -a names=() srcs=()
  local seen=" " skill_md src name
  while IFS= read -r skill_md; do
    src=$(dirname "$skill_md")
    name=$(basename "$src")
    if [[ "$seen" == *" $name "* ]]; then
      echo "error: duplicate skill folder name '$name'" >&2
      return 1
    fi
    seen+="$name "
    names+=("$name")
    srcs+=("$src")
  done < <(find "$REPO_ROOT" -name SKILL.md -not -path '*/.git/*' | sort)

  local td child target i dest
  for td in "${LINK_ROOTS[@]}"; do
    mkdir -p "$td"
    for child in "$td"/*; do
      [[ -L "$child" ]] || continue
      target=$(readlink "$child")
      if [[ "$target" == "$REPO_ROOT"* ]]; then
        rm "$child"
      fi
    done
    for i in "${!names[@]}"; do
      dest="$td/${names[i]}"
      rm -f "$dest"
      ln -s "${srcs[i]}" "$dest"
    done
  done

  echo "Installed ${#names[@]} skill(s)."
  echo "Symlinked into:"
  for td in "${LINK_ROOTS[@]}"; do
    echo "  $td"
  done
}

main "$@"

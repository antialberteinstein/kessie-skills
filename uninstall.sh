#!/usr/bin/env bash
# =============================================================================
# Kessie Skills Uninstaller
# Removes installed skills from Claude Code, Codex, and Gemini CLI
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS=()
for d in "${SCRIPT_DIR}"/*/; do
  if [[ -f "${d}SKILL.md" ]]; then
    SKILLS+=("$(basename "$d")")
  fi
done

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

remove_skill() {
  local skill="$1"
  local dest_dir="$2"
  local target_path="${dest_dir}/${skill}"

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    rm -rf "$target_path"
    echo -e "  ${RED}✗ Removed${NC} ${skill} from ${dest_dir}"
  fi
}

echo -e "${BLUE}=== Kessie Skills Uninstaller ===${NC}"

# Target dirs
DIRS=(
  "${HOME}/.claude/skills"
  "${HOME}/.codex/skills"
  "${HOME}/.agents/skills"
  "${HOME}/.gemini/config/skills"
  "${HOME}/.gemini/skills"
)

for dir in "${DIRS[@]}"; do
  if [[ -d "$dir" ]]; then
    for skill in "${SKILLS[@]}"; do
      remove_skill "$skill" "$dir"
    done
  fi
done

echo -e "\n${GREEN}Uninstallation complete.${NC}"
EOF

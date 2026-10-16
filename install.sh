#!/usr/bin/env bash
# =============================================================================
# Kessie Skills Installer
# Installs/copies or symlinks skills to Claude Code, Codex, and Gemini CLI
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Auto-discover all skills containing SKILL.md
SKILLS=()
for d in "${SCRIPT_DIR}"/*/; do
  if [[ -f "${d}SKILL.md" ]]; then
    SKILLS+=("$(basename "$d")")
  fi
done

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

MODE="copy" # "copy" or "symlink"
TARGETS=()
DRY_RUN=false
LOCAL_DIR=""

usage() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS] [TARGETS...]

Targets:
  claude       Install to Claude Code (~/.claude/skills)
  codex        Install to Codex CLI (~/.agents/skills & ~/.codex/skills)
  gemini       Install to Gemini CLI / Antigravity (~/.gemini/config/skills & ~/.gemini/skills)
  all          Install to all detected harnesses (default if no targets specified)

Options:
  -s, --symlink      Create symbolic links instead of copying (recommended for dev)
  -c, --copy         Copy folders directly (default)
  -l, --local <DIR>  Install locally into a specific project directory (.claude/skills & .agents/skills)
  -n, --dry-run      Show what would be done without making changes
  -h, --help         Show this help message

Examples:
  ./install.sh                     # Auto-detects and installs to all active harnesses (copy)
  ./install.sh -s all              # Symlink to all active harnesses
  ./install.sh claude gemini       # Install only to Claude and Gemini
  ./install.sh -l /path/to/myrepo  # Install locally into a project repository
EOF
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--symlink)
      MODE="symlink"
      shift
      ;;
    -c|--copy)
      MODE="copy"
      shift
      ;;
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -l|--local)
      if [[ -z "${2:-}" ]]; then
        echo -e "${RED}Error: --local requires a directory path.${NC}" >&2
        exit 1
      fi
      LOCAL_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    claude|codex|gemini|all)
      TARGETS+=("$1")
      shift
      ;;
    *)
      echo -e "${RED}Unknown option or target: $1${NC}" >&2
      usage
      exit 1
      ;;
  esac
done

# If no target specified and no local dir, default to "all"
if [[ ${#TARGETS[@]} -eq 0 && -z "$LOCAL_DIR" ]]; then
  TARGETS=("all")
fi

install_skill_to_dir() {
  local skill="$1"
  local dest_dir="$2"
  local skill_src="${SCRIPT_DIR}/${skill}"
  local skill_dest="${dest_dir}/${skill}"

  if [[ ! -d "$skill_src" ]]; then
    echo -e "${YELLOW}Warning: Source skill directory '$skill_src' not found. Skipping.${NC}"
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "[DRY-RUN] Would ${MODE} ${BLUE}${skill}${NC} -> ${dest_dir}/${skill}"
    return
  fi

  mkdir -p "$dest_dir"

  # Remove existing destination if present
  if [[ -L "$skill_dest" || -d "$skill_dest" ]]; then
    rm -rf "$skill_dest"
  fi

  if [[ "$MODE" == "symlink" ]]; then
    ln -s "$skill_src" "$skill_dest"
    echo -e "  ${GREEN}✓ Linked${NC} ${skill} -> ${skill_dest}"
  else
    cp -R "$skill_src" "$skill_dest"
    echo -e "  ${GREEN}✓ Copied${NC} ${skill} -> ${skill_dest}"
  fi
}

echo -e "${BLUE}=== Kessie Skills Installer ===${NC}"
echo -e "Mode: ${YELLOW}${MODE}${NC}"
if [[ "$DRY_RUN" == true ]]; then
  echo -e "Dry run: ${YELLOW}ENABLED${NC}"
fi

# Handle local project install
if [[ -n "$LOCAL_DIR" ]]; then
  echo -e "\nTarget: Project directory (${LOCAL_DIR})"
  if [[ ! -d "$LOCAL_DIR" ]]; then
    echo -e "${RED}Error: Local directory '$LOCAL_DIR' does not exist.${NC}" >&2
    exit 1
  fi

  for skill in "${SKILLS[@]}"; do
    install_skill_to_dir "$skill" "${LOCAL_DIR}/.claude/skills"
    install_skill_to_dir "$skill" "${LOCAL_DIR}/.agents/skills"
  done
fi

# Handle harness targets
has_target() {
  local target="$1"
  for t in "${TARGETS[@]}"; do
    if [[ "$t" == "$target" || "$t" == "all" ]]; then
      return 0
    fi
  done
  return 1
}

# 1. Claude Code (~/.claude/skills)
if has_target "claude"; then
  CLAUDE_DIR="${HOME}/.claude/skills"
  echo -e "\nTarget: Claude Code (${CLAUDE_DIR})"
  for skill in "${SKILLS[@]}"; do
    install_skill_to_dir "$skill" "$CLAUDE_DIR"
  done
fi

# 2. Codex CLI (~/.agents/skills, plus legacy ~/.codex/skills)
if has_target "codex"; then
  CODEX_DIR="${HOME}/.codex/skills"
  AGENTS_DIR="${HOME}/.agents/skills"
  echo -e "\nTarget: Codex CLI (${AGENTS_DIR} & ${CODEX_DIR})"
  for skill in "${SKILLS[@]}"; do
    install_skill_to_dir "$skill" "$AGENTS_DIR"
    install_skill_to_dir "$skill" "$CODEX_DIR"
  done
fi

# 3. Gemini CLI / Antigravity (~/.gemini/config/skills and ~/.gemini/skills)
if has_target "gemini"; then
  GEMINI_CONFIG_DIR="${HOME}/.gemini/config/skills"
  GEMINI_GLOBAL_DIR="${HOME}/.gemini/skills"
  echo -e "\nTarget: Gemini CLI / Antigravity"
  for skill in "${SKILLS[@]}"; do
    install_skill_to_dir "$skill" "$GEMINI_CONFIG_DIR"
    install_skill_to_dir "$skill" "$GEMINI_GLOBAL_DIR"
  done
fi

echo -e "\n${GREEN}Done! Skills are ready to use.${NC}"

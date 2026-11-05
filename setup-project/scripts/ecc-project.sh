#!/usr/bin/env bash
# ecc-project.sh — thêm/gỡ skill và agent của ECC cho project hiện tại (./.claude).
# Dùng bởi skill /setup-project, nhưng chạy tay cũng được.
#
#   ecc-project.sh [-n] add    --skills a,b --agents c,d   thêm (clone tạm, chép, xoá clone)
#   ecc-project.sh [-n] remove --skills a,b --agents c,d   gỡ khỏi ./.claude
#   ecc-project.sh status                                  in những gì đã cài
#
# -n: chạy thử. Bỏ qua thành phần đã có ở ~/.claude (scope user) để không nạp hai lần.
# Ghim phiên bản: ECC_REF=<tag|branch|sha>.  Cần: git, jq.
set -euo pipefail

REPO="https://github.com/affaan-m/ECC"
USER_CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
PROJ="$PWD/.claude"
STATE="$PROJ/ecc/state.json"

DRY=0; [[ "${1:-}" == "-n" ]] && { DRY=1; shift; }
MODE="${1:-}"; shift || true
SKILLS=""; AGENTS=""
while (( $# )); do
  case "$1" in
    --skills) SKILLS="${2:-}"; shift 2 ;;
    --agents) AGENTS="${2:-}"; shift 2 ;;
    *) echo "Tham số lạ: $1" >&2; exit 2 ;;
  esac
done

die() { echo "Lỗi: $*" >&2; exit 1; }
split() { tr ',' '\n' <<<"$1" | sed '/^$/d'; }
command -v jq >/dev/null || die "thiếu jq"
[[ "$PROJ" != "$USER_CFG" ]] || die "đang đứng ở \$HOME; hãy cd vào thư mục project"

state() { [[ -f "$STATE" ]] && cat "$STATE" || echo '{"skills":[],"agents":[]}'; }
save_state() { # jq-filter
  (( DRY == 1 )) && return 0
  mkdir -p "$PROJ/ecc"
  state | jq "$1" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
}

case "$MODE" in
  status)
    [[ -f "$STATE" ]] || { echo "Project chưa cài thành phần ECC nào."; exit 0; }
    jq -r '"commit: \(.commit // "?")\nskills: \(.skills|join(", "))\nagents: \(.agents|join(", "))"' "$STATE"
    exit 0 ;;

  remove)
    for s in $(split "$SKILLS"); do
      [[ "$s" =~ ^[a-z0-9-]+$ ]] || die "tên không hợp lệ: $s"
      echo "  - skill $s"; (( DRY == 1 )) || rm -rf "$PROJ/skills/$s"
      save_state "(.skills -= [\"$s\"])"
    done
    for a in $(split "$AGENTS"); do
      [[ "$a" =~ ^[a-z0-9-]+$ ]] || die "tên không hợp lệ: $a"
      echo "  - agent $a"; (( DRY == 1 )) || rm -f "$PROJ/agents/$a.md"
      save_state "(.agents -= [\"$a\"])"
    done
    exit 0 ;;

  add) ;;
  *) echo "Dùng: ecc-project.sh [-n] add|remove|status [--skills a,b] [--agents c,d]" >&2; exit 2 ;;
esac

command -v git >/dev/null || die "thiếu git"
[[ -n "$SKILLS$AGENTS" ]] || die "không có gì để thêm"

TMP="$(mktemp -d -t ecc-XXXXXX)"; trap 'rm -rf "$TMP"' EXIT
if [[ -n "${ECC_REF:-}" ]]; then
  git clone -q "$REPO" "$TMP/ECC" && git -C "$TMP/ECC" checkout -q "$ECC_REF"
else
  git clone -q --depth 1 "$REPO" "$TMP/ECC"
fi
SHA="$(git -C "$TMP/ECC" rev-parse HEAD)"
echo "ECC $SHA"

bad=0
for s in $(split "$SKILLS"); do [[ -f "$TMP/ECC/skills/$s/SKILL.md" ]] || { echo "Không có skill: $s" >&2; bad=1; }; done
for a in $(split "$AGENTS"); do [[ -f "$TMP/ECC/agents/$a.md" ]] || { echo "Không có agent: $a" >&2; bad=1; }; done
(( bad == 0 )) || die "sửa tên rồi chạy lại; không ghi gì cả"

for s in $(split "$SKILLS"); do
  if [[ -d "$USER_CFG/skills/$s" ]]; then echo "  = skill $s (đã có ở user, bỏ qua)"; continue; fi
  echo "  + skill $s"
  (( DRY == 1 )) && continue
  mkdir -p "$PROJ/skills"; rm -rf "$PROJ/skills/$s"; cp -r "$TMP/ECC/skills/$s" "$PROJ/skills/$s"
  save_state "(.skills |= (. + [\"$s\"] | unique))"
done
for a in $(split "$AGENTS"); do
  if [[ -f "$USER_CFG/agents/$a.md" ]]; then echo "  = agent $a (đã có ở user, bỏ qua)"; continue; fi
  echo "  + agent $a"
  (( DRY == 1 )) && continue
  mkdir -p "$PROJ/agents"; install -m 644 "$TMP/ECC/agents/$a.md" "$PROJ/agents/$a.md"
  save_state "(.agents |= (. + [\"$a\"] | unique))"
done

if (( DRY == 0 )); then
  save_state ".commit = \"$SHA\" | .source = \"$REPO\""
  cp "$TMP/ECC/LICENSE" "$PROJ/ecc/LICENSE"
  echo "Xong. Khởi động lại Claude Code (hoặc /reload-plugins) để nạp."
else
  echo "Chạy thử: chưa ghi gì."
fi

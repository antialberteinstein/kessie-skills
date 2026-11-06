#!/usr/bin/env bash
# harness-check.sh — kiểm tra cấu hình Claude Code (user + project hiện tại). CHỈ ĐỌC.
# In mỗi dòng: OK | WARN | FAIL  <nhóm>  <nội dung>. Không bao giờ in giá trị bí mật.
#
# Dùng:  harness-check.sh            kiểm tra đầy đủ (có gọi mạng để so phiên bản ECC)
#        harness-check.sh --offline  bỏ qua bước gọi mạng
set -uo pipefail

OFFLINE=0; [[ "${1:-}" == "--offline" ]] && OFFLINE=1
U="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
P="$PWD/.claude"; [[ "$P" == "$U" ]] && P=""
nf=0; nw=0
ok()   { echo "OK    $1  $2"; }
warn() { echo "WARN  $1  $2"; nw=$((nw+1)); }
fail() { echo "FAIL  $1  $2"; nf=$((nf+1)); }
have() { command -v "$1" >/dev/null 2>&1; }
tmo() { local s="$1"; shift  # timeout không có sẵn trên macOS
  if have timeout; then timeout "$s" "$@"; elif have gtimeout; then gtimeout "$s" "$@"; else "$@"; fi; }

have jq || { echo "FAIL  tool  thiếu jq"; exit 1; }

# ── 1. JSON hợp lệ ──────────────────────────────────────────────────
FILES=("$U/settings.json")
[[ -n "$P" ]] && FILES+=("$P/settings.json" "$P/settings.local.json")
VALID=()
for f in "${FILES[@]}"; do
  [[ -f "$f" ]] || continue
  if jq empty "$f" 2>/dev/null; then ok json "$f"; VALID+=("$f"); else fail json "$f không phải JSON hợp lệ"; fi
done
[[ -f "$U/settings.json" ]] || warn json "chưa có $U/settings.json"

US="$U/settings.json"; jq empty "$US" 2>/dev/null || US=/dev/null

# ── 2. Plugin ───────────────────────────────────────────────────────
# Gộp enabledPlugins theo thứ tự ưu tiên user < project < local
ENABLED=$(for f in ${VALID[@]+"${VALID[@]}"}; do jq -c '.enabledPlugins // {}' "$f"; done | jq -s -r 'add // {} | to_entries[] | select(.value==true) | .key')
if [[ -n "$ENABLED" ]]; then ok plugin "đang bật: $(echo $ENABLED | tr ' ' ',')"; fi

n_sp=$(grep -c '^superpowers@' <<<"$ENABLED" || true)
(( n_sp > 1 )) && fail plugin "Superpowers bật từ $n_sp marketplace, sẽ nạp trùng"
grep -q '^ecc@' <<<"$ENABLED" && fail plugin "plugin ecc@ đang bật: trùng quy trình với Superpowers"
grep -q '^andrej-karpathy-skills@' <<<"$ENABLED" && grep -q '^ponytail@' <<<"$ENABLED" \
  && warn plugin "Karpathy và ponytail cùng bật: trùng vai trò"
grep -q '^impeccable@' <<<"$ENABLED" && grep -q '^frontend-design@' <<<"$ENABLED" \
  && warn plugin "impeccable và frontend-design cùng bật: hai bộ hướng dẫn thiết kế"

INST="$U/plugins/installed_plugins.json"
if [[ -f "$INST" ]] && jq empty "$INST" 2>/dev/null; then
  for k in $ENABLED; do
    jq -e --arg k "$k" '.plugins[$k] // empty' "$INST" >/dev/null || warn plugin "$k được bật nhưng chưa cài (/plugin hoặc claude-sync)"
  done
fi

lspbin() { # bash 3.2 (macOS) không có mảng kết hợp
  case "$1" in
    typescript-lsp) echo typescript-language-server ;; pyright-lsp) echo pyright-langserver ;;
    clangd-lsp) echo clangd ;; rust-analyzer-lsp) echo rust-analyzer ;; gopls-lsp) echo gopls ;;
    csharp-lsp) echo csharp-ls ;; jdtls-lsp) echo jdtls ;; lua-lsp) echo lua-language-server ;;
    swift-lsp) echo sourcekit-lsp ;;
  esac; }
for k in $ENABLED; do
  b="$(lspbin "${k%@*}")"; [[ -n "$b" ]] || continue
  have "$b" && ok lsp "$k → $b có trong PATH" || fail lsp "$k bật nhưng thiếu '$b' trong PATH"
done

# ── 3. Skill và agent ───────────────────────────────────────────────
list() { # không dùng find -printf (GNU) để chạy được trên macOS
  [[ -d "$1" ]] || return 0
  local e; for e in "$1"/*; do
    [[ -e "$e" || -L "$e" ]] || continue
    [[ -d "$e" || "$e" == *.md ]] && basename "$e" .md
  done | sort; }
US_SK=$(list "$U/skills"); US_AG=$(list "$U/agents")
PR_SK=$([[ -n "$P" ]] && list "$P/skills"); PR_AG=$([[ -n "$P" ]] && list "$P/agents")
cnt() { echo "$1" | sed "/^$/d" | wc -l | tr -d " "; }
ok skill "user: $(cnt "$US_SK") skill, $(cnt "$US_AG") agent | project: $(cnt "$PR_SK") skill, $(cnt "$PR_AG") agent"

for d in $(comm -12 <(echo "$US_SK") <(echo "$PR_SK")); do warn skill "'$d' có ở cả user và project"; done
for d in $(comm -12 <(echo "$US_AG") <(echo "$PR_AG")); do warn agent "'$d' có ở cả user và project"; done

BANNED="tdd-workflow verification-loop planner tdd-guide code-reviewer"
ALL_NAMES=$(printf '%s\n' "$US_SK" "$US_AG" "$PR_SK" "$PR_AG")
for b in $BANNED; do
  grep -qx "$b" <<<"$ALL_NAMES" && warn overlap "'$b' trùng vai trò với Superpowers"
done
for x in $US_SK $PR_SK; do [[ "$x" == orch-* ]] && warn overlap "'$x' trùng vai trò với Superpowers"; done

LEFT=$(grep -rlE '^name: (add-language-rules|database-migration|feature-development|everything-claude-code-conventions)$' "$U" "$HOME/.agents" 2>/dev/null | grep -v '/plugins/cache/' || true)
[[ -n "$LEFT" ]] && while read -r l; do warn leftover "skill ECC cũ còn sót: $l"; done <<<"$LEFT"
for d in rules commands; do
  [[ -d "$U/$d" ]] && [[ -n "$(ls -A "$U/$d" 2>/dev/null)" ]] && warn leftover "~/.claude/$d/ còn $(find "$U/$d" -type f | wc -l | tr -d " ") file, có thể là ECC cũ"
done

# Ước lượng token cho phần description luôn nằm trong context
chars=0
for f in "$U"/skills/*/SKILL.md "$U"/agents/*.md ${P:+"$P"/skills/*/SKILL.md "$P"/agents/*.md}; do
  [[ -f "$f" ]] || continue
  c=$(grep -m1 '^description:' "$f" | wc -c); chars=$((chars + c))
done
tok=$((chars / 4))
(( tok > 4000 )) && warn context "description skill/agent ngoài plugin ≈ $tok token mỗi session" || ok context "description skill/agent ngoài plugin ≈ $tok token mỗi session"

# ── 4. CLAUDE.md ────────────────────────────────────────────────────
if [[ -f "$U/CLAUDE.md" ]]; then
  ok claudemd "$(wc -l <"$U/CLAUDE.md") dòng"
  for s in $(grep -oE '`[a-z0-9-]+` skill|skill `[a-z0-9-]+`' "$U/CLAUDE.md" | grep -oE '[a-z0-9]+(-[a-z0-9]+)+' | sort -u); do
    if [[ -d "$U/skills/$s" ]] || grep -rqsx "name: $s" "$U/plugins/cache" 2>/dev/null; then ok claudemd "skill '$s' được nhắc tới và có tồn tại"
    else warn claudemd "CLAUDE.md nhắc skill '$s' nhưng không tìm thấy skill nào tên vậy"; fi
  done
else
  warn claudemd "chưa có ~/.claude/CLAUDE.md"
fi

# ── 5. Settings khác ────────────────────────────────────────────────
sl=$(jq -r '.statusLine.command // empty' "$US")
if [[ -n "$sl" ]]; then
  f=$(grep -oE '(~|/)[^ "]+\.(sh|js|py)' <<<"$sl" | head -1); f="${f/#\~/$HOME}"
  [[ -z "$f" || -f "$f" ]] && ok settings "statusLine trỏ tới file có thật" || fail settings "statusLine trỏ tới '$f' không tồn tại"
fi
jq -e '.attribution' "$US" >/dev/null 2>&1 && ok settings "đã cấu hình attribution" \
  || warn settings "chưa có khối attribution: commit vẫn có thể kèm Co-Authored-By"
jq -e '.includeCoAuthoredBy' "$US" >/dev/null 2>&1 && warn settings "includeCoAuthoredBy đã bị thay bằng attribution"

for f in ${VALID[@]+"${VALID[@]}"}; do
  for k in $(jq -r '.env // {} | to_entries[] | select(.key|test("TOKEN|SECRET|PASSWORD|API_?KEY|PRIVATE"; "i")) | select((.value|tostring|length) > 0) | .key' "$f"); do
    fail secret "$f có biến môi trường '$k' chứa giá trị (không in ra). Chuyển ra khỏi settings."
  done
done

# ── 6. Hook và ECC ──────────────────────────────────────────────────
nh=$(jq '[.hooks // {} | .[] | .[]] | length' "$US" 2>/dev/null); nh=${nh:-0}
ok hooks "$nh nhóm hook ở user"
if [[ -f "$U/ecc/SOURCE" ]]; then
  sha=$(sed -n 's/^commit: //p' "$U/ecc/SOURCE")
  jq -e '.env.ECC_DISABLED_HOOKS' "$US" >/dev/null 2>&1 || warn ecc "có ECC nhưng chưa đặt ECC_DISABLED_HOOKS: hook tmux, GateGuard… đang bật"
  have node || fail ecc "hook ECC cần node nhưng không có node trong PATH"
  if (( OFFLINE == 0 )) && have git; then
    latest=$(tmo 15 git ls-remote https://github.com/affaan-m/ECC HEAD 2>/dev/null | cut -f1)
    if [[ -z "$latest" ]]; then warn ecc "không kiểm tra được bản ECC mới nhất (mạng?)"
    elif [[ "$latest" == "$sha" ]]; then ok ecc "ECC đang ở bản mới nhất (${sha:0:7})"
    else warn ecc "ECC ${sha:0:7} cũ hơn bản mới nhất ${latest:0:7}: chạy lại install-necessary-ecc-user.sh"; fi
  else
    ok ecc "ECC ${sha:0:7}"
  fi
fi

# ── 7. MCP ──────────────────────────────────────────────────────────
# Scope user nằm trong ~/.claude.json (không phải settings.json); scope project nằm trong ./.mcp.json
CJ="${CLAUDE_CONFIG_DIR:+$CLAUDE_CONFIG_DIR/.claude.json}"; CJ="${CJ:-$HOME/.claude.json}"
PMF=""; [[ -n "$P" ]] && PMF="$PWD/.mcp.json"
MCP_FILES=()
UM=""; PM=""
if [[ -f "$CJ" ]] && jq empty "$CJ" 2>/dev/null; then
  UM=$(jq -r '.mcpServers // {} | keys[]' "$CJ"); MCP_FILES+=("$CJ")
fi
if [[ -n "$PMF" && -f "$PMF" ]]; then
  if jq empty "$PMF" 2>/dev/null; then PM=$(jq -r '.mcpServers // {} | keys[]' "$PMF"); MCP_FILES+=("$PMF")
  else fail mcp "$PMF không phải JSON hợp lệ"; fi
fi
if [[ -n "$UM$PM" ]]; then
  ok mcp "user: $(echo ${UM:-—} | tr ' ' ',') | project: $(echo ${PM:-—} | tr ' ' ',')"
fi
for d in $(comm -12 <(echo "$UM" | sort) <(echo "$PM" | sort)); do
  warn mcp "'$d' khai báo ở cả user và project"
done

# MCP chạy bằng lệnh (stdio) cần lệnh đó có trong PATH
for c in $(for f in ${MCP_FILES[@]+"${MCP_FILES[@]}"}; do jq -r '.mcpServers // {} | .[] | .command // empty' "$f"; done | sort -u); do
  have "$c" && ok mcp "lệnh '$c' có trong PATH" || fail mcp "MCP cần '$c' nhưng không có trong PATH"
done

for f in ${VALID[@]+"${VALID[@]}"}; do
  jq -e '.enableAllProjectMcpServers == true' "$f" >/dev/null 2>&1 \
    && warn mcp "$f bật enableAllProjectMcpServers: MCP trong .mcp.json của repo lạ sẽ tự chạy"
done

# .mcp.json thường được commit: token phải là ${BIẾN}, không được là giá trị cố định
if [[ -n "$PMF" && -f "$PMF" ]] && jq empty "$PMF" 2>/dev/null; then
  while IFS=$'\t' read -r srv kind key; do
    [[ -n "$srv" ]] || continue
    fail secret "$PMF: MCP '$srv' có $kind '$key' chứa giá trị cố định (không in ra). Dùng \${BIẾN_MÔI_TRƯỜNG}."
  done < <(jq -r '.mcpServers // {} | to_entries[] | .key as $n | .value as $v
      | ( ($v.env // {} | to_entries[]
           | select(.key | test("TOKEN|SECRET|PASSWORD|API_?KEY|PRIVATE"; "i"))
           | select((.value | tostring | length) > 0 and ((.value | tostring) | test("\\$\\{") | not))
           | [$n, "env", .key]),
          ($v.headers // {} | to_entries[]
           | select(.key | test("authorization|api[-_]?key|token"; "i"))
           | select((.value | tostring) | test("\\$\\{") | not)
           | [$n, "header", .key]) ) | @tsv' "$PMF")
fi

echo "---"
echo "Tổng: $nf FAIL, $nw WARN"

#!/usr/bin/env bash
# Browse and fetch DESIGN.md files from VoltAgent/awesome-design-md (MIT).
# Usage:
#   design-md.sh list [filter]            list available designs (optionally filtered)
#   design-md.sh show <name>              print the token frontmatter summary of one design
#   design-md.sh fetch <name> <repo-dir> [--force]
#                                         write <repo-dir>/DESIGN.md pinned to the current commit
# Needs curl and python3. Set GITHUB_TOKEN to raise the API rate limit (optional).
set -u
REPO="VoltAgent/awesome-design-md"
API="https://api.github.com/repos/$REPO"
auth=(); [ -n "${GITHUB_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
get() { curl -fsSL ${auth[@]+"${auth[@]}"} -H "Accept: application/vnd.github+json" "$1"; }
valid_name() { printf '%s' "$1" | grep -Eq '^[a-z0-9][a-z0-9.-]{0,63}$'; }
sha() { get "$API/commits/main" | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])'; }
raw() { curl -fsSL "https://raw.githubusercontent.com/$REPO/$1/design-md/$2/DESIGN.md"; }

cmd="${1:-}"; shift || true
case "$cmd" in
  list)
    filter="${1:-}"
    get "$API/contents/design-md" | python3 -c '
import json, sys
f = sys.argv[1].lower()
names = [e["name"] for e in json.load(sys.stdin) if e["type"] == "dir" and f in e["name"].lower()]
print(f"{len(names)} mẫu" + (f" khớp \"{f}\"" if f else "") + ":")
for i in range(0, len(names), 6): print("  " + "  ".join(n.ljust(14) for n in names[i:i+6]))
print("Xem trước: https://getdesign.md/<tên>/design-md")' "$filter" ;;
  show)
    name="${1:-}"; valid_name "$name" || { echo "Tên mẫu không hợp lệ: '$name'" >&2; exit 2; }
    raw main "$name" | python3 -c '
import re, sys
t = sys.stdin.read()
m = re.match(r"^---\n(.*?)\n---\n", t, re.S)
if not m: sys.exit("Không thấy frontmatter")
fm = m.group(1)
desc = re.search(r"^description:\s*(.+)$", fm, re.M)
print("Mô tả:", (desc.group(1).strip().strip("\"")[:400] + "…") if desc else "-")
block = lambda k: re.search(rf"^{k}:\n((?:  .*\n?)+)", fm + "\n", re.M)
c = block("colors")
if c:
    cols = re.findall(r"^  ([a-z0-9-]+):\s*\"?(#[0-9a-fA-F]{3,8})", c.group(1), re.M)
    print("Màu (" + str(len(cols)) + "):", ", ".join(f"{k} {v}" for k, v in cols[:14]), "…" if len(cols) > 14 else "")
fonts = sorted(set(re.findall(r"fontFamily:\s*\"?([^\",\n]+)", fm)))
print("Font:", "; ".join(f.strip("\x27 ") for f in fonts[:5]))
for k in ("rounded", "spacing", "components"):
    b = block(k)
    if b: print(k + ":", len(re.findall(r"^  [a-z0-9-]+:", b.group(1), re.M)), "token")
heads = re.findall(r"^## (.+)$", t[m.end():], re.M)
print("Mục:", " · ".join(heads))'
    echo "Xem trước: https://getdesign.md/$name/design-md" ;;
  fetch)
    name="${1:-}"; dir="${2:-}"; force="${3:-}"
    valid_name "$name" || { echo "Tên mẫu không hợp lệ: '$name'" >&2; exit 2; }
    [ -d "$dir" ] || { echo "Thư mục dự án không tồn tại: $dir" >&2; exit 2; }
    dest="$dir/DESIGN.md"
    if [ -e "$dest" ] && [ "$force" != "--force" ]; then echo "Đã có $dest — không ghi đè (thêm --force nếu người dùng đồng ý)." >&2; exit 1; fi
    commit="$(sha)" || { echo "Không lấy được commit của $REPO" >&2; exit 1; }
    tmp="$(mktemp)"; raw "$commit" "$name" > "$tmp" || { rm -f "$tmp"; echo "Không tải được design-md/$name/DESIGN.md" >&2; exit 1; }
    head -1 "$tmp" | grep -qx -- '---' || { rm -f "$tmp"; echo "File tải về không có frontmatter DESIGN.md hợp lệ" >&2; exit 1; }
    mv "$tmp" "$dest"
    echo "Đã ghi $dest ($(wc -l < "$dest" | tr -d ' ') dòng)"
    echo "Nguồn: $REPO@$commit design-md/$name/DESIGN.md (MIT) — ghi vào ADR thiết kế." ;;
  *) sed -n '2,9p' "$0"; exit 2 ;;
esac

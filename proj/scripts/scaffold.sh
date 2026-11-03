#!/usr/bin/env bash
# Copy the repo-foundation templates into a target repository WITHOUT overwriting anything.
# Usage: scaffold.sh <target-dir> [--name "Project Name"] [--apply]
#   Without --apply it only prints what would be created (dry run).
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
src="$here/templates"
target=""; name=""; apply=0
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) apply=1 ;;
    --name) shift; name="${1:-}" ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) target="$1" ;;
  esac
  shift
done
[ -n "$target" ] || { echo "Cách dùng: $0 <target-dir> [--name \"Tên dự án\"] [--apply]" >&2; exit 2; }
[ -d "$target" ] || { echo "Thư mục đích không tồn tại: $target" >&2; exit 2; }
[ -n "$name" ] || name="$(basename "$(cd "$target" && pwd)")"
today="$(date +%Y-%m-%d)"
esc() { printf '%s' "$1" | sed -e 's/[\/&|]/\\&/g'; }

created=0; skipped=0
while IFS= read -r file; do
  rel="${file#"$src"/}"
  # Templates store dotfiles as dot-<name> so they stay visible; map only path segments that start with it.
  rel="$(printf '%s' "$rel" | sed -E 's#(^|/)dot-#\1.#g')"
  dest="$target/$rel"
  if [ -e "$dest" ]; then
    echo "  = giữ nguyên  $rel (đã tồn tại)"; skipped=$((skipped + 1)); continue
  fi
  if [ "$apply" -eq 1 ]; then
    mkdir -p "$(dirname "$dest")"
    sed -e "s|{{PROJECT_NAME}}|$(esc "$name")|g" -e "s|{{DATE}}|$today|g" "$file" > "$dest"
    echo "  + đã tạo     $rel"
  else
    echo "  + sẽ tạo     $rel"
  fi
  created=$((created + 1))
done < <(find "$src" -type f | sort)

echo
if [ "$apply" -eq 1 ]; then
  echo "Đã tạo $created file, giữ nguyên $skipped file. Tìm 'TODO' trong các file mới để điền nội dung."
else
  echo "Chạy thử: $created file sẽ được tạo, $skipped file đã tồn tại sẽ được giữ nguyên. Thêm --apply để ghi."
fi

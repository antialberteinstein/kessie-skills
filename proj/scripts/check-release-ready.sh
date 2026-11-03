#!/usr/bin/env bash
# Read-only, stack-agnostic pre-release check.
# Usage: check-release-ready.sh X.Y.Z [repo-root]
# Checks: every detected version file equals X.Y.Z, CHANGELOG (Keep a Changelog) has the section,
# tag vX.Y.Z does not exist yet, working tree clean, default branch synced (when on it).
set -u
version="${1:-}"; root="${2:-.}"
printf '%s' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$' || { echo "Cách dùng: $0 X.Y.Z [repo-root]" >&2; exit 2; }
cd "$root" || exit 2
problems=0
ok() { echo "  ✓ $1"; }; bad() { echo "  ✗ $1"; problems=$((problems + 1)); }; note() { echo "  • $1"; }
check() { if [ "$2" = "$version" ]; then ok "$1 = $2"; else bad "$1 = '${2:-?}', cần $version"; fi; }

echo "File phiên bản:"
n=0
if [ -f package.json ]; then check package.json "$(node -p 'require("./package.json").version' 2>/dev/null)"; n=$((n+1)); fi
if [ -f package-lock.json ]; then check package-lock.json "$(node -p 'require("./package-lock.json").version' 2>/dev/null)"; n=$((n+1)); fi
if [ -f app.json ] && grep -q '"version"' app.json; then check app.json "$(node -p 'const a=require("./app.json");(a.expo||a).version' 2>/dev/null)"; n=$((n+1)); fi
for f in pyproject.toml Cargo.toml; do
  if [ -f "$f" ]; then check "$f" "$(grep -m1 -E '^version *= *"' "$f" | sed -E 's/.*"(.*)".*/\1/')"; n=$((n+1)); fi
done
if [ -f pubspec.yaml ]; then check "pubspec.yaml (bỏ +build)" "$(grep -m1 '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)"; n=$((n+1)); fi
[ "$n" -eq 0 ] && note "không thấy file phiên bản quen thuộc — kiểm tra thủ công nơi lưu version"

echo "CHANGELOG.md:"
if [ -f CHANGELOG.md ]; then
  if grep -q '^## \[Unreleased\]' CHANGELOG.md; then ok "còn mục [Unreleased]"; else bad "thiếu '## [Unreleased]'"; fi
  if grep -Eq "^## \[$version\] - [0-9]{4}-[0-9]{2}-[0-9]{2}" CHANGELOG.md; then
    lines="$(awk -v v="## [$version]" 'index($0,v)==1{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | grep -c '^[[:space:]]*- ')"
    if [ "$lines" -gt 0 ]; then ok "mục [$version] có $lines dòng"; else bad "mục [$version] trống"; fi
  else bad "thiếu '## [$version] - YYYY-MM-DD'"; fi
  if grep -q '^\[Unreleased\]: ' CHANGELOG.md; then
    if grep -q "^\[$version\]: " CHANGELOG.md; then ok "có link [$version]"; else bad "thiếu link '[$version]: …compare/vPREV...v$version'"; fi
    if grep -q "^\[Unreleased\]: .*v$version\.\.\.HEAD" CHANGELOG.md; then ok "[Unreleased] so sánh từ v$version"; else bad "[Unreleased] chưa trỏ v$version...HEAD"; fi
  else note "CHANGELOG không dùng link so sánh cuối file (tùy chọn)"; fi
else bad "chưa có CHANGELOG.md"; fi

echo "README:"
if [ -f README.md ] && grep -q "version" README.md; then
  if grep -q "$version" README.md; then ok "README nhắc $version"; else note "README có chữ 'version' nhưng không có $version — badge/ghi chú phiên bản có cần cập nhật?"; fi
fi

echo "Git:"
has_origin=0
if git remote get-url origin >/dev/null 2>&1; then has_origin=1; git fetch -q origin 2>/dev/null || note "không fetch được origin"; else note "chưa có remote origin — bỏ qua so sánh với remote"; fi
if git rev-parse -q --verify "refs/tags/v$version" >/dev/null || { [ "$has_origin" -eq 1 ] && git ls-remote --exit-code --tags origin "v$version" >/dev/null 2>&1; }; then
  note "tag v$version đã tồn tại — không di chuyển/dùng lại tag; phát hành bản mới nếu sai"
else ok "tag v$version chưa tồn tại"; fi
base="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)"; default="${base#origin/}"
branch="$(git rev-parse --abbrev-ref HEAD)"; note "nhánh hiện tại: $branch (gốc: $default)"
if [ "$has_origin" -eq 1 ] && [ "$branch" = "$default" ]; then
  if [ "$(git rev-parse HEAD)" = "$(git rev-parse "$base" 2>/dev/null)" ]; then ok "$default trùng $base"; else bad "$default chưa trùng $base — pull trước khi gắn tag"; fi
fi
if [ -z "$(git status --porcelain --untracked-files=no)" ]; then ok "không có thay đổi chưa commit"; else bad "có thay đổi chưa commit"; fi

echo
if [ "$problems" -eq 0 ]; then echo "Sẵn sàng cho bước tiếp theo của release $version."; else echo "$problems vấn đề cần xử lý." >&2; exit 1; fi

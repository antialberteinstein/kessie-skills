#!/usr/bin/env bash
# Read-only, stack-agnostic snapshot of a repository for planning and status reports.
# Usage: project-snapshot.sh [repo-root]
set -u
root="${1:-.}"
cd "$root" || { echo "Không mở được $root" >&2; exit 2; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo "$root không phải git repo" >&2; exit 2; }
section() { printf '\n## %s\n' "$1"; }
list_or_none() { if [ -n "$1" ]; then printf '%s\n' "$1"; else echo "  (không có)"; fi; }

if ! git rev-parse -q --verify HEAD >/dev/null; then
  section "Git"
  echo "Repo chưa có commit nào. Commit nền tảng (scaffold, tài liệu) trước khi bắt đầu code — mỗi giai đoạn sau là một PR."
  echo "File hiện có:"; list_or_none "$(git status --porcelain | sed 's/^/  /')"
  exit 0
fi
if git remote get-url origin >/dev/null 2>&1; then
  git fetch -q --prune origin 2>/dev/null || echo "(không fetch được origin — dùng dữ liệu local)"
else
  echo "(chưa có remote origin — chỉ dùng dữ liệu local)"
fi
base="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)"
[ -z "$base" ] && for b in origin/main origin/master main master; do git rev-parse -q --verify "$b" >/dev/null && { base="$b"; break; }; done
[ -z "$base" ] && base="$(git rev-parse --abbrev-ref HEAD)"
default="${base#origin/}"

section "Git"
echo "Nhánh hiện tại: $(git rev-parse --abbrev-ref HEAD) · nhánh gốc: $base"
if git rev-parse -q --verify "$default" >/dev/null && [ "$base" != "$default" ]; then
  git rev-list --left-right --count "$default...$base" | awk -v d="$default" '{print d " local: ahead " $1 ", behind " $2}'
fi
echo "Nhánh local đã merge vào $base (có thể dọn — hỏi trước):"
list_or_none "$(git branch --merged "$base" --format='%(refname:short)' 2>/dev/null | grep -vx "$default" | sed 's/^/  - /')"
echo "Nhánh local chưa merge:"
list_or_none "$(git branch --no-merged "$base" --format='%(refname:short)' 2>/dev/null | sed 's/^/  - /')"
echo "Thay đổi chưa commit / file chưa theo dõi:"
list_or_none "$(git status --porcelain | sed 's/^/  /')"
echo "Commit gần nhất trên $base:"
git log --format='  %h %ad %s' --date=short -5 "$base" 2>/dev/null

section "Phiên bản"
found=0
[ -f package.json ] && { echo "package.json: $(node -p 'require("./package.json").version' 2>/dev/null || grep -m1 '"version"' package.json)"; found=1; }
[ -f app.json ] && grep -q '"version"' app.json && { echo "app.json: $(node -p 'const a=require("./app.json");(a.expo||a).version' 2>/dev/null)"; found=1; }
for f in pyproject.toml Cargo.toml; do [ -f "$f" ] && { echo "$f: $(grep -m1 -E '^version *= *"' "$f" | sed -E 's/.*"(.*)".*/\1/')"; found=1; }; done
[ -f pubspec.yaml ] && { echo "pubspec.yaml: $(grep -m1 '^version:' pubspec.yaml | awk '{print $2}')"; found=1; }
[ "$found" -eq 0 ] && echo "(không thấy file phiên bản quen thuộc)"
tag="$(git describe --tags --abbrev=0 "$base" 2>/dev/null || true)"
echo "Tag mới nhất: ${tag:--}"
[ -n "$tag" ] && echo "Commit kể từ $tag: $(git rev-list --count "$tag..$base")"
if [ -f CHANGELOG.md ]; then
  unrel="$(awk '/^## \[Unreleased\]/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | grep -v '^[[:space:]]*$' | grep -v '^\[[^]]*\]: ' | grep -v '^<!--')"
  echo "CHANGELOG [Unreleased]:"; list_or_none "$(printf '%s' "$unrel" | sed 's/^/  /' | head -20)"
else
  echo "Chưa có CHANGELOG.md"
fi

section "Theo dõi local (nên gom về issue tracker)"
for f in ISSUES.md TODO.md BACKLOG.md ROADMAP.md docs/ImplementationStatus.md docs/STATUS.md; do
  [ -f "$f" ] || continue
  open="$(grep -n '^[[:space:]]*- \[ \]' "$f" | head -15 | sed 's/^/    /')"
  echo "  $f (sửa lần cuối $(git log -1 --format=%ad --date=short -- "$f" 2>/dev/null || echo '?')):"
  list_or_none "$open"
done

section "GitHub"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && gh repo view >/dev/null 2>&1; then
  echo "Issue đang mở:"; list_or_none "$(gh issue list --state open --limit 50 | sed 's/^/  /')"
  echo "PR đang mở:"; list_or_none "$(gh pr list --state open --limit 50 | sed 's/^/  /')"
  echo "Milestone đang mở:"
  list_or_none "$(gh api 'repos/{owner}/{repo}/milestones?state=open' --jq '.[] | "  - \(.title): \(.open_issues) mở / \(.closed_issues) đóng, hạn \(.due_on // "-")"' 2>/dev/null)"
  echo "Release gần nhất:"; list_or_none "$(gh release list --limit 3 2>/dev/null | sed 's/^/  /')"
  echo "CI trên $default (3 lần gần nhất):"; list_or_none "$(gh run list --branch "$default" --limit 3 2>/dev/null | sed 's/^/  /')"
else
  echo "(gh chưa cài/đăng nhập hoặc repo chưa có remote GitHub — bỏ qua)"
fi

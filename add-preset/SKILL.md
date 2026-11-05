---
name: add-preset
description: Thêm hoặc sửa một nhóm (preset) trong catalog của /setup-project, sau khi tra cứu thành phần thật trong ECC và marketplace chính thức
disable-model-invocation: true
---

# /add-preset

Thêm một nhóm mới vào catalog mà `/setup-project` dùng, hoặc sửa một nhóm có sẵn.

Yêu cầu: $ARGUMENTS
Ví dụ: `quantum: project dùng qiskit, cirq`, `sửa ml: thêm agent rag`.
Nếu yêu cầu trống hoặc không rõ project loại gì, hỏi một câu rồi mới làm.

## Phạm vi
- Chỉ sửa `catalog.md` trong **bản clone của repo kessie-skills**, không sửa bản đã cài
  trong `~/.claude/plugins/` (bản đó bị ghi đè khi cập nhật).
- Không tự `git push`. Không cài gì cả; cài là việc của `/setup-project`.

## 1. Tìm repo kessie
Dùng biến môi trường `KESSIE_REPO`; nếu trống thì thử thư mục hiện tại, rồi `~/src/kessie-skills`.
Repo hợp lệ khi có `.claude-plugin/marketplace.json` và file
`setup-project/catalog.md` (skill nằm ở gốc repo, không có thư mục `skills/`). Không tìm thấy thì hỏi đường dẫn.
Nếu repo có thay đổi chưa commit, báo và hỏi trước khi làm tiếp.

## 2. Đọc catalog hiện tại
Đọc toàn bộ để nắm định dạng, các nhóm đã có, và mục "Không bao giờ đề xuất".
Nếu nhóm cần thêm trùng ý với nhóm có sẵn, đề xuất sửa nhóm đó thay vì thêm mới.

## 3. Tra cứu thành phần thật
```bash
T=$(mktemp -d); git clone -q --depth 1 https://github.com/affaan-m/ECC "$T/ECC"
grep -H -m1 '^description:' "$T"/ECC/skills/*/SKILL.md "$T"/ECC/agents/*.md
```
Plugin chính thức: đọc `marketplace.json` của `claude-plugins-official` trong
`~/.claude/plugins/marketplaces/`; nếu không có thì clone tạm
`https://github.com/anthropics/claude-plugins-official`.

Chọn thành phần khớp với loại project. Loại bỏ mọi thứ trong mục "Không bao giờ đề
xuất". Với mỗi agent được chọn, `grep` xem nó có nhắc tới skill/rule khác không; nếu có
thì thêm skill đó vào nhóm hoặc bỏ agent. Xoá thư mục tạm khi xong: `rm -rf "$T"`.

## 4. Đề xuất và chờ xác nhận
Trình bày nhóm mới **đúng định dạng catalog**: tên nhóm, dòng "Dấu hiệu" (tên
dependency, file, thư mục cụ thể), danh sách skills/agents/plugin. Thêm một dòng giải
thích cho từng thành phần được chọn và những thành phần đã cân nhắc nhưng bỏ.
Dừng lại chờ người dùng đồng ý hoặc chỉnh.

## 5. Ghi và kiểm tra
- Chèn nhóm vào phần "Thành phần ECC" (hoặc bảng plugin) của `catalog.md`.
- Kiểm tra lại mọi tên vừa ghi đều tồn tại trong bản clone ECC hoặc marketplace.
- Chạy `claude plugin validate "$KESSIE_REPO"`.
- Hiện `git diff`, hỏi người dùng có muốn commit không. Nếu có, commit với message
  dạng `feat(catalog): add <tên nhóm> preset`, không kèm dòng attribution nào.

## 6. Báo người dùng bước còn lại
```bash
git -C "$KESSIE_REPO" push
claude plugin marketplace update kessie
```
rồi `/reload-plugins` trong Claude Code. Sau đó `/setup-project` sẽ thấy nhóm mới.

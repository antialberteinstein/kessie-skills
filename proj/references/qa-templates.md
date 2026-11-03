# Mẫu QA

## 1. Kế hoạch kiểm thử theo AC

| AC | Lớp | Test (file › tên) | Cần thiết bị/môi trường thật? |
|---|---|---|---|
| AC-01 | E2E | e2e/<module>.spec › "…" | Không |
| AC-04 | DB cô lập | db-tests/<suite> | Không |
| AC-06 | Thiết bị | checklist §… | **Có** |

## 2. Báo cáo bằng chứng

```markdown
### Kiểm chứng <tính năng/issue> — YYYY-MM-DD
| AC | Bằng chứng | Kết quả |
|----|------------|---------|
| AC-01 | e2e … (desktop + mobile) | Đạt |
| AC-04 | DB cô lập: suite … | Đạt (cô lập) |
| AC-06 | — | Chưa xác minh: cần thiết bị |

Lệnh: typecheck/lint/format đạt · unit <n>/<n> (lines <..>%, branches <..>%) · e2e <m>/<m> · DB <suites> · build đạt.
Chưa xác minh: <…>. Coverage chỉ tính trên file đo, không đại diện toàn app.
```

## 3. Checklist thiết bị / môi trường thật

**Thiết bị/trình duyệt** ___ · **OS** ___ · **Bản cài** vX.Y.Z (artifact release) ___ · **Ngày** ___ · **Mạng** ___

### Cài đặt và phiên
- [ ] App mở độc lập (dev server đã tắt); icon và tên đúng.
- [ ] Đăng ký, xác nhận, đăng nhập; mạng yếu thì báo lỗi trong thời gian hợp lý, không treo.
- [ ] Đóng hẳn rồi mở lại vẫn giữ phiên; đăng xuất xoá phiên.
- [ ] Đổi tài khoản không còn dữ liệu của tài khoản trước.

### Mỗi module (lấy từ AC "cần thiết bị")
- [ ] Nhập liệu: bàn phím đúng loại, không có hai bàn phím cùng lúc, picker ngày có giới hạn.
- [ ] Back: khi bàn phím mở chỉ ẩn bàn phím; không mất bản nháp.
- [ ] Tạo, sửa, xoá; mở lại app vẫn đúng dữ liệu và thứ tự.

### Quyền và tích hợp
- [ ] Quyền (ảnh, thông báo, vị trí) hỏi đúng lúc; từ chối thì app vẫn chạy.
- [ ] Thông báo hoặc push nhận được (ghi độ trễ); fallback hoạt động khi thiếu cấu hình.
- [ ] Theme sáng/tối và ngôn ngữ không còn chữ sót.

### Kết luận
Đạt / Không đạt · Issue phát sinh · Ảnh đã che

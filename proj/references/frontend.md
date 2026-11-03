# UI, client và E2E

## Kiến trúc client (áp dụng cho mọi framework)

| Tầng | Chứa | Không chứa |
|---|---|---|
| `domain/` | Kiểu dữ liệu, schema validation, quy tắc nghiệp vụ thuần (tính tổng, sắp xếp, lọc, parse biểu thức) | I/O, UI |
| `data/` | Repository, adapter duy nhất gọi backend, state toàn app | Logic hiển thị |
| `services/` | Auth client, thông báo, map lỗi, tích hợp nền tảng | Component |
| `ui/` | Màn hình, component dùng chung, điều hướng | Gọi backend trực tiếp |

Logic trong `domain/` là thuần, nên unit test được mà không cần UI hay mạng.

## Quy tắc từ ngày đầu

1. **i18n và theme ngay từ component đầu tiên.** Mọi chữ đi qua hàm dịch (ví dụ `t("Tiếng Việt", "English")` hoặc khoá i18n). Màu lấy từ token của theme. Thêm sau sẽ rất tốn công.
2. **Component chữ dùng chung.** Trên native, chữ phải nằm trong component Text. Thêm test tĩnh (quét AST) để chặn chữ trần nếu framework đòi hỏi.
3. **Nhãn trợ năng ổn định** (`accessibilityLabel`, `aria-label`, `Semantics`) đồng thời là selector cho E2E (`getByRole(name)`). Không dùng selector theo CSS hay thứ tự phần tử.
4. **Form giữ bản nháp:** đi sang trang phụ (tạo danh mục hoặc người liên quan), hủy dialog, Back khi bàn phím mở đều không làm mất dữ liệu đang nhập. Nút lưu bị khoá khi đang lưu, không gửi trùng.
5. **Nhập số tiền:** dùng parser an toàn (không `eval`), số nguyên theo đơn vị nhỏ nhất. Cân nhắc keypad riêng nếu cần phép tính. Ngày dùng picker có giới hạn (ví dụ không chọn ngày tương lai).
6. **Lỗi:** chỉ hiển thị thông báo đã map theo mã. Có trạng thái lỗi kèm hành động (thử lại, đăng xuất). Không hiển thị message thô của server.
7. **Thứ tự và tổng lấy từ domain.** UI không tự sắp xếp hay tính lại.
8. **Mobile-first:** kiểm tra ở viewport điện thoại nhỏ, không tràn ngang. Thẻ gọn, vùng chạm ≥ 44pt. Vùng chạm sửa tách khỏi switch và nút xoá.
9. **Điều hướng:** quyết định sớm (thư viện hay tự viết), ghi ADR. Không thêm thư viện điều hướng hay UI kit giữa chừng khi chưa hỏi người dùng.
10. **Hiệu năng:** list dài dùng virtualization, ghi nhớ kết quả lọc và nhóm, tránh tính toán lặp trong render.

## E2E với backend giả lập

- Chặn request tới backend ở tầng mạng (Playwright `page.route`, MSW, mock HTTP client). Giữ state trong bộ nhớ của test, để reload vẫn còn dữ liệu.
- **Không** thêm đường tắt đăng nhập hay "test mode" vào bundle phát hành.
- Chạy ít nhất hai project: desktop và mobile viewport (nếu có bản web).
- Mỗi test gom lỗi runtime (`pageerror`, `console.error`) và kiểm tra không có lỗi. Kiểm tra không tràn ngang: `document.documentElement.scrollWidth <= innerWidth`.
- Luồng tối thiểu: tạo, sửa, xoá, hủy xoá; reload giữ dữ liệu và thứ tự; nhập sai không lưu được; trạng thái trống; lỗi server hiển thị thông báo đã map.
- Có script chụp ảnh màn hình sáng/tối trên desktop và mobile để review. Xem ảnh trước khi báo xong.

Cấu hình Playwright tối thiểu cho app có web build:

```ts
projects: [
  { name: "desktop", use: { ...devices["Desktop Chrome"] } },
  { name: "mobile", use: { ...devices["iPhone 13"], defaultBrowserType: "chromium" } },
],
webServer: { command: "<lệnh chạy web>", url: "http://127.0.0.1:<port>", reuseExistingServer: !process.env.CI },
```

## Giới hạn của web và emulator

Web preview và emulator **không** chứng minh được: bàn phím hệ thống, nút Back phần cứng, date picker native, quyền (ảnh, thông báo), secure storage, push. Thay đổi chạm vào các phần này cần ghi "cần xác minh trên thiết bị" trong PR và thêm vào checklist của `/kessie-skills:proj ship` › qa.

Skill bên ngoài: tuỳ framework, ví dụ `react-native-best-practices` (Callstack), `vercel-react-best-practices`, `expo-*` (Expo), `flutter-expert` (Jeffallan); chung: `frontend-ui-engineering` (addyosmani), `webapp-testing` (Anthropic), `accessibility-compliance` (wshobson).

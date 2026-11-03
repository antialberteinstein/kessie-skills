# Loại dự án và cách điều chỉnh quy trình

Một dự án có thể thuộc nhiều loại (ví dụ app mobile + API riêng). Gộp yêu cầu của các loại liên quan. Ghi loại dự án vào idea brief và CLAUDE.md.

## Bảng tổng hợp

| Loại | Đặc tả (giai đoạn 1) | Quyết định kiến trúc trọng tâm | AC bắt buộc (ngoài AC chức năng) | Lớp kiểm thử chính | Kênh phát hành |
|---|---|---|---|---|---|
| **A. App có dữ liệu người dùng** (mobile/desktop, một người sở hữu dữ liệu) | Đầy đủ: RequirementsOutline + module breakdown | Client framework, BaaS hay backend riêng, Auth, phân quyền theo chủ sở hữu, push/job nền | Trống · nhập sai · reload giữ dữ liệu · **tài khoản khác bị từ chối** · lỗi mạng không thành công giả · native (Back, bàn phím, quyền) | Unit · E2E (mock backend) · DB/emulator cô lập · **thiết bị thật** | Bản cài (APK/IPA/desktop) + checksum, hoặc store |
| **B. Web app / SaaS nhiều người dùng** (team, tổ chức) | Đầy đủ + mô hình vai trò (owner/admin/member) | Mô hình tenant (cột `org_id` + membership), phân quyền theo vai trò, môi trường staging/prod, billing (nếu có) | Như A + **người ngoài tổ chức bị từ chối** · đúng quyền theo từng vai trò · mời/rời tổ chức · dữ liệu không rò giữa tenant | Unit · E2E · test phân quyền theo vai trò · smoke test trên staging | Deploy (preview → staging → production), có rollback |
| **C. API / service** | RequirementsOutline rút gọn + **hợp đồng API** (OpenAPI/GraphQL schema) | Framework, DB, authn/authz middleware, versioning API, deploy, quan sát (log/metrics) | 401 thiếu token · 403/404 khi truy cập tài nguyên người khác · 422 dữ liệu sai · idempotency cho thao tác ghi · giới hạn tốc độ | Unit · test API/contract · DB cô lập · smoke test sau deploy | Deploy hoặc image container; changelog API; deprecation policy |
| **D. Thư viện / SDK / package** | **API công khai** + ví dụ sử dụng; không cần module breakdown kiểu UI | Ngôn ngữ và runtime hỗ trợ, phạm vi API công khai, dependency tối thiểu, chính sách semver | Ví dụ trong README chạy được · đầu vào sai báo lỗi rõ · không phá vỡ API giữa minor · chạy trên mọi runtime được hỗ trợ | Unit · test ma trận runtime · kiểm tra kiểu và API công khai · doc test | Publish lên registry (npm/PyPI/crates/pub) có provenance; tag + Release |
| **E. CLI** | Danh sách lệnh, cờ, ví dụ; mã thoát | Ngôn ngữ, phân phối (binary, npm -g, brew, pipx), cấu hình (file/env) | `--help` đúng · mã thoát đúng · stdout là dữ liệu, stderr là thông báo · không hỏi khi không có TTY · chạy được trên các OS hỗ trợ | Unit · **golden test** (so khớp output) · test ma trận OS | Binary theo OS + checksum, hoặc publish package; công thức brew (tùy chọn) |
| **F. Site tĩnh / landing / docs** | Rút gọn: danh sách trang, nội dung, mục tiêu SEO; không cần ADR backend | Generator, hosting, form hoặc analytics (quyền riêng tư) | Không link hỏng · a11y cơ bản · hiển thị đúng trên mobile · meta/OG đúng | Build · kiểm tra link · Lighthouse/a11y · preview deploy | Deploy hosting tĩnh (preview cho mỗi PR) |
| **G. Data / automation / script** | Đầu vào, đầu ra, lịch chạy, nguồn dữ liệu | Runtime, lịch (cron/CI), nơi lưu dữ liệu, secret | Chạy lại cho cùng kết quả (idempotent) · dry-run · dữ liệu sai bị từ chối có log · không lộ dữ liệu thật trong log | Unit · test với dữ liệu mẫu nhỏ · chạy thử trên bản sao dữ liệu | Job đã lên lịch, hoặc package; hướng dẫn chạy |
| **H. Extension / bot / tích hợp** | Quyền cần xin, sự kiện, luồng tương tác | API nền tảng (Chrome, Slack, Discord, Telegram…), lưu token, webhook | Chỉ xin quyền tối thiểu · token không lộ · xử lý giới hạn tốc độ · webhook xác thực chữ ký | Unit · test với mock API nền tảng · thử trên workspace hoặc trình duyệt thật | Store của nền tảng (cần review), hoặc tự host |

## Giai đoạn nào rút gọn được

| Loại | Bỏ hoặc rút gọn |
|---|---|
| D, E | Không có phân quyền dữ liệu, không có checklist thiết bị; `build` › frontend chỉ dùng nếu có UI |
| F | Không có ADR backend hay phân quyền; đặc tả có thể chỉ 1 trang; milestone có thể chỉ một |
| G | Không có E2E UI; thay bằng chạy thử trên bản sao dữ liệu |
| C | Không có frontend; "thiết bị thật" thay bằng smoke test sau deploy |

**Không bao giờ bỏ:** idea brief (kể cả nửa trang), ADR stack, CLAUDE.md, CI, CHANGELOG, quy trình issue → PR, báo cáo bằng chứng có phần chưa xác minh.

## Câu hỏi để xác định loại

1. Có giao diện người dùng không (app, web, CLI, không có)?
2. Ai sở hữu dữ liệu: một người, một nhóm, hay không có dữ liệu người dùng?
3. Sản phẩm được **dùng** (app, site), được **gọi** (API, bot), hay được **cài vào code khác** (thư viện)?
4. Phát hành bằng cách nào: bản cài, deploy, publish lên registry, hay lịch chạy?

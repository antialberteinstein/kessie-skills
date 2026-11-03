# Ma trận chọn stack và các bộ tham khảo

## Ma trận chấm điểm (1–5, nhân trọng số)

| Tiêu chí | Trọng số | Phương án A | Phương án B | Phương án C |
|---|---:|---:|---:|---:|
| Khớp nền tảng đích | 3 | | | |
| Phân quyền dữ liệu mạnh, kiểm thử được | 3 | | | |
| Chi phí ở quy mô dự kiến (gói miễn phí?) | 2 | | | |
| Kỹ năng sẵn có của người dùng | 2 | | | |
| Mức phụ thuộc nhà cung cấp / khả năng rời đi | 2 | | | |
| Công cụ kiểm thử cục bộ (DB cô lập, emulator) | 2 | | | |
| Hệ sinh thái và tài liệu, skill có sẵn cho agent | 1 | | | |
| **Tổng** | | | | |

Điểm chỉ để hỗ trợ trao đổi. Quyết định cuối cùng ghi ở ADR, kèm lý do bằng lời.

## Các bộ stack tham khảo cho app cá nhân (không phải khuyến nghị cố định)

| Bộ | Phù hợp khi | Phân quyền dữ liệu | Lưu ý |
|---|---|---|---|
| React Native/Expo + Supabase (Postgres, RLS, Storage, Edge Functions) | Mobile đa nền tảng, dữ liệu quan hệ, muốn SQL và test DB cô lập | RLS `owner = auth.uid()`, FK ghép `(owner_id, ref_id)` chặn tham chiếu chéo | Remote push cần dev build; quyết định sớm cách áp dụng migration |
| Flutter + Firebase (Auth, Firestore, Functions, FCM) | Mobile, dữ liệu dạng tài liệu, cần push và offline sẵn có | Security Rules theo `request.auth.uid`, test bằng emulator | Truy vấn tổng hợp hạn chế; Functions cần gói Blaze |
| Next.js/Remix + Postgres (Neon/Supabase) + ORM | Web trước, có server action | Middleware + RLS hoặc kiểm tra owner trong mọi truy vấn | Logic nằm ở server, test API thay cho test RLS |
| Native (SwiftUI/Kotlin) + CloudKit/Room | Một nền tảng, cần trải nghiệm native sâu | Do nền tảng quản lý | Hai codebase nếu sau này cần nền tảng thứ hai |
| Backend riêng (FastAPI/NestJS/Go) + Postgres | Logic server nhiều, tích hợp bên thứ ba, thanh toán | Middleware authz + ràng buộc DB + test API | Tự lo deploy, giám sát, bảo mật hạ tầng |

## Câu hỏi kiểm tra nhanh trước khi chấp nhận

- [ ] Có đúng **một** nguồn danh tính không?
- [ ] Mọi dữ liệu người dùng có phân quyền ở tầng dữ liệu hoặc server (không chỉ ở client)?
- [ ] Có cách chạy test phân quyền **cục bộ, cô lập** (DB container, emulator)?
- [ ] Biến public là gì và secret nằm ở đâu?
- [ ] Dịch vụ tùy chọn (push, analytics) thiếu cấu hình thì app vẫn chạy được không?
- [ ] Chi phí khi có 10 lần số người dùng dự kiến?

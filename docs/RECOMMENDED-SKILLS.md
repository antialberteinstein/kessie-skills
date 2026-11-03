# Skill nên dùng cùng plugin kessie-skills

Số liệu lấy từ GitHub API ngày **2026-11-03**. Tên skill đã đối chiếu với `SKILL.md` thật của từng repo. Kiểm tra lại trước khi cài.

## Bộ tối thiểu (khuyến nghị)

| Thành phần | Vai trò | Ghi chú |
|---|---|---|
| Plugin `kessie-skills` (một lệnh `/kessie-skills:proj`, nhiều chế độ) | Quy trình cá nhân: khởi động · làm issue/PR · kiểm chứng và phát hành · quản lý và bảo trì | Chỉ chạy khi gọi lệnh, không tốn ngữ cảnh khi không dùng |
| [`karpathy-guidelines`](https://github.com/multica-ai/andrej-karpathy-skills) (229k★) | Nguyên tắc hành vi: nghĩ trước khi code, đơn giản trước, sửa đúng chỗ, định nghĩa "xong" | 1 skill, không có hook, không phụ thuộc stack. **Luôn bật** |
| Plan mode có sẵn của Claude Code (Shift+Tab hai lần) | Lập kế hoạch chỉ đọc rồi chờ duyệt | Không cần cài gì |
| Skill chính chủ của stack đã chọn (phụ lục) | Kiến thức về framework và dịch vụ | Chỉ thêm sau khi đã có ADR chọn stack |

Skill tự kích hoạt chỉ còn karpathy + skill của stack, nên Claude ít chọn nhầm. `kessie-skills` và ECC có thể cài song song: muốn dùng quy trình nào thì gọi lệnh của quy trình đó.

## Tùy chọn (chỉ thêm khi thực sự thiếu)

| Repo | ★ | Khi nào thêm | Chỉ lấy |
|---|---:|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | 312k | Muốn kỷ luật TDD và debug chặt hơn | `test-driven-development`, `systematic-debugging`, `verification-before-completion` |
| [mattpocock/skills](https://github.com/mattpocock/skills) | 311k | Hay làm việc lớn qua nhiều phiên, cần tách ticket | `grill-me`, `to-tickets`, `triage`, `wayfinder` |
| [getsentry/skills](https://github.com/getsentry/skills) | 1.1k | Muốn review bảo mật PR và GitHub Actions kỹ hơn | `security-review`, `gha-security-review`, `agents-md` |
| [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | 46k | Review PR nhiều agent | plugin `code-review`, `pr-review-toolkit` |
| [anthropics/skills](https://github.com/anthropics/skills) | 187k | Tạo hoặc tinh chỉnh skill riêng | `skill-creator` |

Chọn lẻ từng skill (`npx skills add <repo> --skill <tên>`), không cài nguyên bộ. Không dùng nhiều framework quy trình cùng lúc.

## Không khuyến nghị

| | Lý do |
|---|---|
| **everything-claude-code (ECC)** làm mặc định | Khoảng 230 skill đang bật cùng hook và rule toàn cục. Nó phủ khoảng một nửa phần kỹ thuật của `kessie-skills`, nhưng rải trên nhiều skill và command trùng nhau (xem bảng dưới), thiên về web và team (Docker, Linear, BullMQ). Rule toàn cục `~/.claude/rules/node.md` và `everything-claude-code-guardrails.md` (CommonJS, camelCase) áp lên mọi dự án. Hook GateGuard (`scripts/hooks/gateguard-fact-force.js`) chặn mỗi lần ghi file mới để đòi trình bày thông tin. Nếu cần một phần nào đó, tắt plugin toàn cục rồi chép riêng skill cần dùng |
| **`everything-claude-code:plan`** | Lệnh chung chung "nhắc lại yêu cầu → rủi ro → các giai đoạn → chờ xác nhận". Plan mode có sẵn đã làm đúng việc này. `/kessie-skills:proj build` đã yêu cầu dùng Plan mode cho việc lớn |
| **ponytail** ([DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), 183k★) | Trùng mục tiêu với karpathy (chống viết code thừa). Nặng hơn: 6 skill, 6 lệnh; bản trong cache (cho Hermes Agent) còn có hook chạy trước mỗi lần gọi model. Đã chọn karpathy. Trên máy ponytail đang ở trạng thái cài nhưng chưa bật |
| Danh sách tổng hợp (ComposioHQ, VoltAgent, alirezarezvani 380+ skill…) | Chỉ dùng để khám phá; chất lượng không đồng đều, quá rộng để cài |

### ECC so với kessie-skills

| Chế độ của proj | Skill ECC tương ứng | ECC thiếu gì |
|---|---|---|
| `/kessie-skills:proj kickoff` | `prp-prd`, `product-capability`, `blueprint`, `architecture-decision-records`, `codebase-onboarding` | Cổng giai đoạn; bộ AC bắt buộc (truy cập chéo, reload, lỗi mạng, native); ADR "Bị loại"; scaffold và template; 10 bài học |
| `/kessie-skills:proj build` | `prp-plan`, `prp-implement`, `prp-pr`, `feature-dev`, `tdd-workflow`, `git-workflow`, `database-migrations`, `e2e-testing` | Quy tắc Closes/Refs; PR 3 phần; test phân quyền cho 3 nền tảng (mẫu SQL đã chạy thử) |
| `/kessie-skills:proj ship` | `verification-loop`, `security-review`, `deployment-patterns`, `github-ops` | Bảng "lớp nào chứng minh gì"; checklist thiết bị; script kiểm tra trước release; quy tắc tag và pre-release 0.x |
| `/kessie-skills:proj status` | `github-ops`, `project-flow-ops` (GitHub + Linear) | Script snapshot đa stack; quy tắc một backlog; triage Dependabot cho gói do framework ghim |

## Phụ lục: skill chính chủ theo stack

| Stack | Repo | ★ | Skill |
|---|---|---:|---|
| Expo / React Native | [expo/skills](https://github.com/expo/skills) | 4.0k | `expo-upgrade`, `expo-dev-client`, `eas-workflows`, `eas-update`, `eas-app-stores` |
| React Native | [callstackincubator/agent-skills](https://github.com/callstackincubator/agent-skills) | 1.7k | `react-native-best-practices`, `upgrading-react-native` |
| React / Next.js | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | 33.5k | `vercel-react-best-practices`, `vercel-react-native-skills` |
| Supabase / Postgres | [supabase/agent-skills](https://github.com/supabase/agent-skills) | 3.0k | `supabase`, `supabase-postgres-best-practices` |
| Stack khác | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | 12.2k | `flutter-expert`, `nextjs-developer`, `fastapi-expert`, `swift-expert`… (persona cộng đồng, không phải chính chủ) |

Nguồn: GitHub API (`repos`, `git/trees`, `contents/*/SKILL.md`, 2026-11-03); nội dung ECC 1.10.0, ponytail 4.8.4, karpathy-skills 1.0.0 trong `~/.claude/plugins/cache`; [Expo docs: Agent skills](https://docs.expo.dev/skills/); [supabase/agent-skills](https://github.com/supabase/agent-skills).

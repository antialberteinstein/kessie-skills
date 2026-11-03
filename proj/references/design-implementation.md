# Áp dụng DESIGN.md theo stack

DESIGN.md có frontmatter YAML: `colors` (tên → hex), `typography` (tên → fontFamily, fontSize, fontWeight, lineHeight, letterSpacing), `rounded`, `spacing`, `components` (tên → thuộc tính tham chiếu token dạng `"{colors.primary}"`). Phần thân mô tả Overview, Colors, Typography, Layout, Elevation, Components, Responsive và Do's/Don'ts. Đọc cả hai: frontmatter là số liệu, phần thân là quy tắc dùng.

## Ánh xạ token

| Stack | File token (một nguồn) | Cách dùng |
|---|---|---|
| Web + CSS | `src/styles/tokens.css`: `:root { --color-primary: …; --radius-md: …; --space-4: … }` và `[data-theme="dark"] { … }` hoặc `@media (prefers-color-scheme: dark)` | Component dùng `var(--color-primary)` |
| Tailwind v4 | `@theme { --color-primary: …; --radius-md: …; --font-sans: … }` trong CSS chính | Class `bg-primary`, `rounded-md` sinh từ token |
| Tailwind v3 | `tailwind.config` → `theme.extend.colors/borderRadius/spacing/fontFamily` đọc từ một module token | Như trên |
| React Native / Expo | `src/ui/theme.ts`: `export const light = {…}; export const dark = {…}` + hook (`useTheme()`) | `StyleSheet` lấy màu từ hook; không hardcode hex trong màn hình |
| Flutter | `lib/theme/tokens.dart` → `ColorScheme`, `TextTheme`, `ThemeData(useMaterial3: true)` cho sáng và tối | `Theme.of(context).colorScheme.primary` |
| SwiftUI | Asset catalog Color Set (Any/Dark) + `extension Color` + `Font` helpers | `Color.brandPrimary` |
| Jetpack Compose | `ui/theme/Color.kt`, `Type.kt`, `Shape.kt` → `MaterialTheme(colorScheme, typography, shapes)` | `MaterialTheme.colorScheme.primary` |

Quy ước tên: giữ tên token của DESIGN.md (`primary`, `ink`, `canvas`, `body-md`, `rounded.lg`) để đối chiếu dễ. Token dạng `{colors.x}` trong `components` được giải thành biến tương ứng.

## Checklist áp dụng

- [ ] Một file token; không có hex hay kích thước cứng trong component (grep `#[0-9a-fA-F]{6}` ngoài file token).
- [ ] Theme sáng và tối (tối được người dùng duyệt nếu là bản suy ra).
- [ ] Font: license hợp lệ, có fallback, hiển thị đúng tiếng Việt có dấu (nếu UI tiếng Việt).
- [ ] Tương phản đạt WCAG AA (`contrast.mjs`). Trạng thái focus nhìn thấy được.
- [ ] Vùng chạm ≥ 44pt trên mobile; quy tắc responsive trong DESIGN.md được áp dụng.
- [ ] Trang style guide hiển thị màu, chữ, nút, input, thẻ ở cả hai theme.
- [ ] Ảnh trước/sau (sáng/tối, mobile/desktop) đính vào PR.
- [ ] Không dùng logo, tên, minh hoạ hay font độc quyền của thương hiệu gốc.

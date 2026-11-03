---
version: alpha
name: <Tên dự án>-design
description: <2–4 câu: cảm giác tổng thể, màu chủ đạo (#hex) dùng cho việc gì, kiểu chữ, hình khối (bo góc), mật độ.>

colors:
  primary: "#2563eb"
  on-primary: "#ffffff"
  primary-active: "#1d4ed8"
  ink: "#111827"
  body: "#374151"
  mute: "#6b7280"
  canvas: "#ffffff"
  surface: "#f9fafb"
  hairline: "#e5e7eb"
  positive: "#16a34a"
  warning: "#d97706"
  negative: "#dc2626"

typography:
  display-lg:
    fontFamily: "'Be Vietnam Pro', Inter, system-ui, sans-serif"
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: -0.2px
  title-md:
    fontFamily: "'Be Vietnam Pro', Inter, system-ui, sans-serif"
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: 0
  body-md:
    fontFamily: "'Be Vietnam Pro', Inter, system-ui, sans-serif"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 0
  button-md:
    fontFamily: "'Be Vietnam Pro', Inter, system-ui, sans-serif"
    fontSize: 15px
    fontWeight: 600
    lineHeight: 1
    letterSpacing: 0

rounded:
  none: 0px
  sm: 6px
  md: 10px
  lg: 16px
  full: 9999px

spacing:
  xs: 4px
  sm: 8px
  md: 12px
  base: 16px
  lg: 24px
  xl: 32px

components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-md}"
    rounded: "{rounded.md}"
    padding: 12px 20px
    height: 44px
  card:
    backgroundColor: "{colors.canvas}"
    borderColor: "{colors.hairline}"
    rounded: "{rounded.lg}"
    padding: "{spacing.base}"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    rounded: "{rounded.md}"
    height: 44px
---

## Overview
<Tinh thần thiết kế, đối tượng, điều làm nên nhận diện.>

## Colors
<Vai trò từng nhóm màu: thương hiệu, bề mặt, chữ, ngữ nghĩa. Màu nào chỉ dùng cho CTA chính.>

## Typography
<Thang chữ, khi nào dùng từng cỡ, font thay thế.>

## Layout
<Lưới, khoảng cách, độ rộng tối đa, mật độ.>

## Elevation & Depth
<Bóng đổ hay viền; cách phân tầng.>

## Components
<Quy tắc cho nút, thẻ, input, điều hướng, danh sách, trạng thái trống/lỗi.>

## Responsive Behavior
<Breakpoint, vùng chạm tối thiểu 44pt, cách thu gọn trên mobile.>

## Dark Mode
<Ánh xạ màu sang theme tối.>

## Do's and Don'ts
- Do: …
- Don't: …

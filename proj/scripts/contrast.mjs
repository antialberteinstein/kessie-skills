#!/usr/bin/env node
// WCAG 2.x contrast ratio for color pairs. Usage: contrast.mjs <fg> <bg> [<fg> <bg> ...]
// Colors: #rgb, #rrggbb (alpha not supported). Thresholds: text 4.5, large text/UI 3.0.
const pairs = process.argv.slice(2);
if (pairs.length === 0 || pairs.length % 2) { console.error("Cách dùng: contrast.mjs <fg> <bg> [<fg> <bg> ...]"); process.exit(2); }
const parse = (h) => {
  const m = /^#?([0-9a-f]{3}|[0-9a-f]{6})$/i.exec(h); if (!m) throw new Error(`Màu không hợp lệ: ${h}`);
  const s = m[1].length === 3 ? [...m[1]].map((c) => c + c).join("") : m[1];
  return [0, 2, 4].map((i) => parseInt(s.slice(i, i + 2), 16) / 255);
};
const lum = (rgb) => { const [r, g, b] = rgb.map((c) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4)); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };
let fail = 0;
for (let i = 0; i < pairs.length; i += 2) {
  const [a, b] = [lum(parse(pairs[i])), lum(parse(pairs[i + 1]))];
  const ratio = (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
  const verdict = ratio >= 4.5 ? "đạt (chữ thường)" : ratio >= 3 ? "chỉ đạt chữ lớn/UI" : "KHÔNG đạt";
  if (ratio < 4.5) fail++;
  console.log(`${pairs[i]} trên ${pairs[i + 1]}: ${ratio.toFixed(2)}:1 — ${verdict}`);
}
process.exit(fail ? 1 : 0);

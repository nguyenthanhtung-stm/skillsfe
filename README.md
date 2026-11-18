# skillsfe

Bộ skill front-end cho Claude Code / Claude Desktop: Next.js App Router + TypeScript + Tailwind + **shadcn/ui** + **SWR** + **Redux Toolkit**.

| Skill | Việc |
|---|---|
| `fe-code-chuan` | Chuẩn code React/Next.js: **khung dự án dựng trước** (TS chặt, ESLint, Prettier, husky + lint-staged, shadcn, SWR, Redux — đã chạy thử), SWR + Redux chuẩn production, ngân sách JS, 70 quy tắc hiệu năng Vercel, chia component, danh sách tự soát |
| `fe-giao-dien` | Giao diện có chủ đích (Anthropic frontend-design) + sàn chất lượng UI/accessibility (Vercel Web Interface Guidelines), Việt hoá, theme riêng trên shadcn |
| `shadcn` | Skill **chính chủ** của shadcn/ui (bản sao nguyên văn từ `shadcn-ui/ui`, không sửa) |

## Cài (một lệnh, Windows)

```powershell
git clone https://github.com/nguyenthanhtung-stm/skillsfe.git D:\skillsfe; powershell -ExecutionPolicy Bypass -File D:\skillsfe\cai-dat.ps1
```

Script liên kết (junction) từng skill vào `~/.claude/skills`, nên `git -C D:\skillsfe pull` là cập nhật, không cần cài lại.
Mở phiên Claude mới để skill hiện ra.

## Dùng

Không cần gõ lệnh: làm việc FE (tạo dự án Next.js, viết page/component, lấy dữ liệu, Redux, review UI) thì skill tự kích hoạt.
Gọi tay: `/fe-code-chuan`, `/fe-giao-dien`.

Dự án mới: Claude dựng khung theo `skills/fe-code-chuan/references/khung-du-an.md` **trước** mọi tính năng; `npm run check`
là cổng kiểm chung.

Dùng cùng skill `giao-deepseek` (repo `skills`): Phase 0 = khung này, lệnh kiểm mọi phase = `npm run check`.

## Đã chạy thử (2026-11-18)

Next 16.4.6, React 19.3, ESLint 9, shadcn CLI 4.23 (`base-nova`, Base UI 1.9), SWR 2.5.1, RTK 2.14, React-Redux 9.3:
`check` + `build` xanh từ bản checkout sạch, hook chặn commit bẩn, trang mẫu (bảng đơn hàng shadcn + SWR có fallback server +
giỏ Redux + theme riêng) chạy đúng trên trình duyệt, ~187 KB JS (nén) lần tải đầu.

## Nguồn và giấy phép

Mỗi skill có `NGUON.md`: Vercel agent-skills (MIT), Anthropic frontend-design (Apache-2.0), Vercel Web Interface Guidelines
(MIT), shadcn/ui (MIT), tài liệu chính chủ Redux, SWR, Next.js.

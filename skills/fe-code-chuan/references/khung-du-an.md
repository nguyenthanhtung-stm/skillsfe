# Khung dự án Next.js — dựng ĐẦU TIÊN, trước mọi tính năng

Mục đích: ngay commit đầu tiên đã có TypeScript strict, lint, format, hook chặn commit bẩn, shadcn/ui, SWR, khung Redux. Code rác không lọt
vào repo từ ngày một. Nguồn: tài liệu Next.js *ESLint Plugin* (cập nhật 2026-10-15) + Redux *Setup with Next.js* + SWR *With Next.js* + skill chính chủ `shadcn`.

Trong quy trình giao-deepseek đây là **Phase 0 — Claude tự làm** (DeepSeek không được cài gói). Xong Phase 0 phải chạy
`npm run check` xanh rồi mới commit và viết kế hoạch các phase tính năng.

## Bước 1. Tạo dự án

```bash
npx create-next-app@latest <ten-du-an> --ts --eslint --tailwind --app --src-dir --import-alias "@/*" --use-npm
```
Đã chạy thử 2026-11-18 với Next 16.4.6, React 19.3, ESLint 9, shadcn CLI 4.23 (style `base-nova`, Base UI 1.9), SWR 2.5.1,
RTK 2.14, React-Redux 9.3: `check` + `build` xanh từ bản checkout sạch, hook chặn đúng commit bẩn; trang mẫu (bảng đơn hàng
shadcn + SWR có fallback server + giỏ Redux) chạy đúng trên trình duyệt, không gọi API trùng, không lỗi console. Next 16 tự sinh `AGENTS.md` (hướng Claude đọc tài liệu Next đúng
phiên bản trong `node_modules/next/dist/docs/`) — giữ lại.

Có sẵn: TypeScript, ESLint flat config (`core-web-vitals` + `typescript`), Tailwind, App Router. (Next 16+: **không còn
`next lint`**, chạy `eslint` trực tiếp.) Kiểm `package.json` → ghi phiên bản Next/React vào `docs/kien-truc.md`.

## Bước 2. TypeScript chặt hơn

`tsconfig.json` → `compilerOptions` thêm:
```json
"strict": true,
"noUncheckedIndexedAccess": true,
"noImplicitOverride": true,
"noFallthroughCasesInSwitch": true,
"forceConsistentCasingInFileNames": true
```

## Bước 3. ESLint + Prettier

```bash
npm i -D prettier eslint-config-prettier prettier-plugin-tailwindcss
```

`eslint.config.mjs`
```js
import { defineConfig, globalIgnores } from 'eslint/config'
import nextVitals from 'eslint-config-next/core-web-vitals'
import nextTs from 'eslint-config-next/typescript'
import prettier from 'eslint-config-prettier/flat'

export default defineConfig([
  ...nextVitals,
  ...nextTs,
  {
    rules: {
      // chất lượng
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      eqeqeq: ['error', 'always'],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/ban-ts-comment': ['error', { 'ts-ignore': true, 'ts-expect-error': 'allow-with-description' }],
      // Redux: chỉ dùng hook có kiểu
      '@typescript-eslint/no-restricted-imports': ['error', {
        paths: [{ name: 'react-redux', importNames: ['useSelector', 'useDispatch', 'useStore'],
                  message: 'Dùng useAppSelector / useAppDispatch / useAppStore từ @/lib/hooks.' }],
      }],
    },
  },
  // hooks.ts là nơi duy nhất được import hook gốc để tạo hook có kiểu
  { files: ['**/lib/hooks.ts'], rules: { '@typescript-eslint/no-restricted-imports': 'off' } },
  prettier, // luôn đặt sau cùng trong các bộ quy tắc: tắt luật định dạng trùng với Prettier
  globalIgnores(['.next/**', 'out/**', 'build/**', 'next-env.d.ts']),
])
```

`.prettierrc.json`
```json
{ "semi": false, "singleQuote": true, "trailingComma": "all", "printWidth": 110, "plugins": ["prettier-plugin-tailwindcss"] }
```
(Dự án đã có quy ước khác thì theo dự án; quan trọng là có **một** file cấu hình.)

`.prettierignore`: `.next`, `out`, `build`, `node_modules`, `package-lock.json`.

`.gitattributes` (bắt buộc trên Windows — không có thì git đổi xuống dòng sang CRLF, `prettier --check` báo sai cả repo):
```
* text=auto eol=lf
```

## Bước 4. Script kiểm tra một lệnh

`package.json` → `scripts`:
```json
"lint": "eslint . --max-warnings=0",
"lint:fix": "eslint . --fix",
"format": "prettier --write .",
"format:check": "prettier --check .",
"typecheck": "next typegen && tsc --noEmit",
"check": "npm run typecheck && npm run lint && npm run format:check"
```
`next typegen` bắt buộc: Next 16 sinh kiểu route (`LayoutProps`, `PageProps`) vào `.next/`; trên bản checkout sạch / CI
thiếu bước này thì `tsc` báo lỗi `Cannot find name 'LayoutProps'`.
`npm run check` là cổng chung: Dev tự chạy, Tester/QA chạy, nghiệm thu chạy, CI chạy (+ `next build`).

## Bước 5. Chặn commit bẩn (husky + lint-staged)

```bash
npm i -D husky lint-staged
npx husky init
```
Ghi đè `.husky/pre-commit` thành:
```
npx lint-staged
npm run typecheck
```
`.lintstagedrc.mjs`
```js
import path from 'node:path'

const rel = (files) => files.map((f) => `"${path.relative(process.cwd(), f)}"`).join(' ')

// gán biến rồi mới export: luật import/no-anonymous-default-export của Next chặn export object vô danh
const config = {
  '*.{js,jsx,ts,tsx,mjs}': (files) => [`eslint --fix --max-warnings=0 ${rel(files)}`, `prettier --write ${rel(files)}`],
  '*.{json,css,md}': (files) => `prettier --write ${rel(files)}`,
}

export default config
```
Kiểm hook: tạo thử một file có `any`, `@ts-ignore`, `==`, `import { useSelector } from 'react-redux'` → `git commit` phải bị chặn.

## Bước 6. shadcn/ui (bộ component đã chốt)

Theo skill chính chủ `shadcn` (đã cài cùng bộ skill). Lệnh:
```bash
npx shadcn@latest init --defaults -y
npx shadcn@latest add button card table input field select dialog skeleton empty badge separator
```
- `--defaults` = mẫu Next, style `base-nova`, nền **Base UI**, icon `lucide`, màu theo biến CSS trong `src/app/globals.css`.
  Đổi bộ màu/font cho đúng thương hiệu bằng preset (`npx shadcn@latest apply <code> --only theme,font`) hoặc sửa biến trong
  `globals.css` — làm cùng skill `fe-giao-dien` để không ra giao diện mặc định ai cũng giống.
- **Bắt buộc ngay sau `init` — theme và font riêng** (đã gặp khi chạy thử, bỏ qua là ra trang trắng xám, chữ Times):
  1. `init` để lại `--font-sans: var(--font-sans)` (tự trỏ vào chính nó) trong `@theme inline` của `globals.css` → font hỏng,
     trình duyệt rơi về Times. Sửa: trong `layout.tsx` nạp font có **subset `vietnamese`** bằng `next/font/google`
     (vd `Be_Vietnam_Pro({ variable: '--font-be-vietnam', subsets: ['latin', 'vietnamese'], weight: [...] })`), gắn
     `className={font.variable}` vào `<html lang="vi">`, rồi đặt `--font-sans: var(--font-be-vietnam)` và
     `--font-heading` tương tự; `--font-mono` không dùng Geist thì đặt `ui-monospace, monospace`.
  2. Bộ màu `neutral` mặc định chỉ có trắng/đen/xám → đặt `--primary`, `--background`, `--secondary`, `--accent`, `--border`,
     `--ring`, `--radius`… theo phương án màu của `fe-giao-dien`. Thêm token trạng thái `--success`, `--warning`, `--info`
     (cả `:root` và `.dark`), khai `--color-success: var(--success)`… trong `@theme inline`, và thêm biến thể `success` /
     `warning` / `info` vào `badge.tsx` (vd `success: 'bg-success/12 text-success'`) — trạng thái dùng biến thể, không màu thô.
  3. Sửa `globals.css` xong mà trang vẫn ra màu cũ → bộ đệm Turbopack giữ CSS cũ: **xoá `.next/` rồi build lại**.
- Gói `cn` mà shadcn thêm vào là của chính shadcn (repo `shadcn-ui/cn`, thay `clsx` + `tailwind-merge`) — bình thường.
- Code component được **chép vào `src/components/ui/`**: là code của dự án, chịu đủ luật lint. **Sau mỗi lần `shadcn add`**:
  `npm run lint:fix` rồi sửa tay phần còn lại (lần thử: `field.tsx` có `==` → sửa `===`), chạy `npm run check` trước khi commit.
- **Chỉ thêm component thật sự dùng** (giữ nhẹ); không `add --all`.
- Viết giao diện theo luật của skill `shadcn`: màu ngữ nghĩa (`bg-primary`, không `bg-blue-500`), `gap-*` không `space-y-*`,
  form dùng `FieldGroup` + `Field`, trạng thái rỗng dùng `Empty`, đang tải dùng `Skeleton`, nút đang chạy = `Spinner` + `disabled`.

## Bước 7. SWR (dữ liệu server ở client)

```bash
npm i swr
```
Tạo theo `swr.md` mục 3–4: `src/lib/swr/fetcher.ts` (ném lỗi khi `!res.ok`), `src/lib/swr/keys.ts`, `src/app/SwrProvider.tsx`,
và **một hook tài nguyên mẫu** (`src/features/<ten>/use<Ten>.ts`) + trang mẫu có `fallback` từ server.

## Bước 8. Khung Redux (state toàn cục thuần client)

```bash
npm i @reduxjs/toolkit react-redux
```
Tạo đúng các file theo `redux.md` mục 4–5: `lib/store.ts`, `lib/hooks.ts`, `lib/createAppAsyncThunk.ts`,
`lib/listenerMiddleware.ts`, `app/StoreProvider.tsx`, và **một slice mẫu** đầy đủ (state có kiểu, action dạng sự kiện,
selector, test) để Dev bắt chước. Không RTK Query (dữ liệu server do SWR lo).

`app/layout.tsx` bọc theo thứ tự:
```tsx
<StoreProvider>
  <SwrProvider>{children}</SwrProvider>
</StoreProvider>
```

## Bước 9. Giữ nhẹ — ngân sách JS

Số đo thật trang mẫu (đã nén, tải lần đầu): khung Next + React **~118 KB** (không tránh được), Redux + Immer **~36 KB**,
Base UI (shadcn) **~17 KB**, SWR + code trang **~15 KB** → tổng **~187 KB**.
- Ngân sách: **≤ 220 KB JS mỗi trang** lần tải đầu; mỗi tính năng thêm **≤ 30 KB**. Đo: mở trang ở trình duyệt, DevTools
  Network lọc JS (hoặc `performance.getEntriesByType('resource')`), xoá cache trước khi đo.
- Server component là mặc định; `"use client"` chỉ ở lá tương tác.
- Thư viện nặng (biểu đồ, trình soạn thảo, xuất Excel/PDF) nạp bằng `next/dynamic` khi cần.
- Icon import từng cái từ `lucide-react`; ngày giờ dùng `Intl`; không `moment`, không `lodash` cả gói.
- `next/font` tối đa 2 họ, `subsets: ['latin', 'vietnamese']`.
- Redux là khoản lớn nhất phía ứng dụng: chỉ dùng khi thật sự có state toàn cục nhiều màn hình cùng sửa.

## Bước 10. Thư viện dùng chung cho mọi phase (cài luôn bây giờ, Dev không được cài)

Theo nhu cầu đã chốt ở BA, ví dụ: `zod` (kiểm dữ liệu vào Server Action/form), `react-hook-form` + `@hookform/resolvers`,
`vitest` + `@testing-library/react` + `jsdom` (test), `@playwright/test` (E2E). Thêm script `test`, `e2e` tương ứng.

## Bước 11. Chốt khung

1. Xoá `.next/`, chạy `npm run check` và `npm run build` xanh, không cảnh báo; mở trang mẫu ở trình duyệt: không lỗi console,
   JS trong ngân sách.
2. Ghi `docs/kien-truc.md`: phiên bản, cấu trúc thư mục, nơi đặt component/slice/hook SWR/key, quy ước đặt tên, lệnh kiểm.
3. `git init` (nếu chưa) → commit đầu `chore: khung du an`. Mọi phase sau nghiệm thu bằng `git diff` từ commit này.

## Không được (ghi luôn vào mục "Không được làm" của mọi kế hoạch FE)

- Tắt/nới luật lint, thêm `eslint-disable`, `@ts-ignore`, `any` để cho qua.
- Sửa `eslint.config.mjs`, `tsconfig.json`, `.prettierrc.json`, `.husky/`, `lib/store.ts`, `lib/swr/fetcher.ts`,
  `components.json`, biến màu trong `globals.css` khi kế hoạch không giao.
- Cài thêm gói, `shadcn add` component mới, viết component UI tự chế khi shadcn đã có (Dev báo "CẦN CÀI" / "CẦN COMPONENT").
- Gọi API bằng `useEffect` + `fetch` tự viết thay cho hook SWR; dùng màu thô (`bg-blue-500`) thay biến ngữ nghĩa.
- Commit bằng `--no-verify`.

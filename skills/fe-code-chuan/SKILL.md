---
name: fe-code-chuan
description: Chuẩn viết code front-end React / Next.js (App Router) — dựng khung dự án trước (TS chặt, ESLint, Prettier, husky, shadcn/ui, SWR, Redux), SWR và Redux Toolkit chuẩn production, giữ nhẹ (ngân sách JS), hiệu năng, ranh giới server/client, chia component, tự soát. Dùng khi tạo dự án Next.js mới, viết, sửa, review hoặc lập kế hoạch code React/Next.js (component, page, Server Action, lấy dữ liệu SWR, Redux store/slice, lint). Gộp từ Vercel react-best-practices + composition-patterns. Giao diện/thẩm mỹ thì dùng skill fe-giao-dien.
---

# FE code chuẩn (React / Next.js)

Một skill gộp: quy trình ngắn + các quy tắc quan trọng nhất ngay trong file này, chi tiết từng quy tắc (ví dụ sai/đúng) ở `references/`.

## 0. Trước khi viết

1. Đọc `package.json`: phiên bản **Next** và **React** (React 19 → bỏ `forwardRef`; Next 15+ → `params`/`searchParams`/`cookies()` là async; Next 16.3+ → có `AGENTS.md` và tài liệu trong `node_modules/next/dist/docs/` — đọc nó, đúng phiên bản hơn trí nhớ).
2. Xem dự án đang dùng gì và **theo đúng cái đó**. Dự án mới theo **stack đã chốt**: Next.js App Router + TypeScript + Tailwind + **shadcn/ui** (skill `shadcn`) + **SWR** (dữ liệu server ở client) + **Redux Toolkit** (state toàn cục thuần client); không RTK Query, không React Query. Không tự thêm thư viện mới.
3. Tìm một component/page tương tự đã có và bắt chước cấu trúc, đặt tên.

**Dự án mới hoặc dự án chưa có lint/format/hook commit → dựng khung TRƯỚC mọi tính năng** theo
`references/khung-du-an.md`: create-next-app → TS chặt → ESLint + Prettier → script `npm run check` → husky + lint-staged →
shadcn → SWR → khung Redux → ngân sách JS → thư viện dùng chung → `check` + `build` xanh → commit đầu. Không viết tính năng
trên dự án chưa có khung.

## 1. Ranh giới Server / Client (App Router)

- Mặc định là **Server Component**. Chỉ thêm `"use client"` cho lá cần state, effect, sự kiện, API trình duyệt — đẩy `"use client"` xuống **càng sâu càng tốt**, không đặt ở layout/page.
- Lấy dữ liệu ở server component (async), truyền xuống client **chỉ trường cần dùng** (`server-serialization`, `server-dedup-props`).
- Không để biến module dùng chung lưu dữ liệu theo request (`server-no-shared-module-state`).
- Mỗi route cần thì có `loading.tsx`, `error.tsx`, `not-found.tsx`; bọc phần chậm bằng `<Suspense>` để stream (`async-suspense-boundaries`).
- **Server Action = API công khai**: luôn xác thực + phân quyền + kiểm dữ liệu vào (zod hoặc tương đương) bên trong action (`server-auth-actions`). Không tin dữ liệu client gửi.
- Bí mật chỉ ở server; biến `NEXT_PUBLIC_*` là công khai.

## 2. Quy tắc theo mức ảnh hưởng

Làm từ trên xuống; hai nhóm đầu là lỗi nặng nhất.

| Ưu tiên | Nhóm | Điểm chính | Tiền tố file |
|---|---|---|---|
| 1 NGHIÊM TRỌNG | Thác nước async | `Promise.all` cho việc độc lập; khởi động promise sớm, `await` muộn; `await` vào đúng nhánh dùng | `async-` |
| 2 NGHIÊM TRỌNG | Kích thước bundle | import thẳng file, tránh barrel `index.ts`; `next/dynamic` cho component nặng; nạp analytics sau hydrate | `bundle-` |
| 3 CAO | Server | `React.cache()` khử trùng lặp trong request; fetch song song bằng cách tách component; `after()` cho việc không chặn | `server-` |
| 4 TRUNG-CAO | Lấy dữ liệu ở client | SWR/React Query để khử trùng lặp; listener passive; localStorage có version | `client-` |
| 5 TRUNG | Re-render | tính state dẫn xuất ngay khi render, **không** dùng effect; `setState(fn)`; không khai báo component bên trong component; `startTransition` cho cập nhật không gấp | `rerender-` |
| 6 TRUNG | Render | dùng `? :` thay `&&` khi vế trái có thể là số; `content-visibility` cho danh sách dài; chống nháy khi hydrate | `rendering-` |
| 7 THẤP | JavaScript | `Map`/`Set` để tra cứu; gộp vòng lặp; thoát sớm; RegExp ngoài vòng lặp | `js-` |
| 8 THẤP | Nâng cao | ref cho handler, khởi tạo một lần | `advanced-` |

Danh sách đủ 70 quy tắc: `references/hieu-nang/_sections.md`; mỗi quy tắc một file `references/hieu-nang/<tên>.md` (ví dụ `async-parallel.md`, `bundle-barrel-imports.md`). **Chỉ mở file của quy tắc đang cần**, không đọc hết.

## 3. Chia component (composition)

- **Không thêm prop boolean để rẽ nhánh hành vi** (`isCompact`, `showX`, `variantY`...) — tách component biến thể rõ ràng hoặc component ghép (`<Card><Card.Header/>…`) (`architecture-avoid-boolean-props`, `patterns-explicit-variants`).
- Component phức tạp → compound component dùng chung context (`architecture-compound-components`).
- Provider là nơi duy nhất biết state quản lý thế nào; context có giao diện `{ state, actions, meta }` (`state-*`).
- Ưu tiên `children` hơn prop `renderX` (`patterns-children-over-render-props`).
- React 19: không `forwardRef` (ref là prop), dùng `use(Context)` (`react19-no-forwardref`).

Chi tiết: `references/thanh-phan/<tên>.md`.

## 3a. Lấy dữ liệu (SWR)

Bộ quy tắc + khung code: **`references/swr.md`** — đọc trước khi viết chỗ lấy/ghi dữ liệu. Cốt lõi:

- Chỉ hiển thị → `fetch` trong server component. Cần làm mới/tương tác ở client → SWR. Ghi → Server Action hoặc
  `useSWRMutation`, xong `mutate` đúng key.
- Một fetcher chung (ném lỗi khi `!res.ok`), một file `keys.ts`, hook theo tài nguyên (`useOrders`), component không gọi URL trực tiếp.
- Dữ liệu ban đầu: `SWRConfig` `fallback` + `revalidateIfStale: false` (không gọi trùng). Đủ 3 trạng thái tải / lỗi / rỗng.

## 3b. Redux (Redux Toolkit)

Bộ quy tắc đầy đủ + khung code: **`references/redux.md`** — đọc trước khi tạo/sửa store, slice, thunk. Cốt lõi:

- Redux chỉ cho state **toàn cục thuần client, dùng chung, thay đổi được**. Dữ liệu server → server component / SWR (không chép
  vào slice); bộ lọc, tab, trang → URL; ô nhập form → state cục bộ.
- Next.js: **không store toàn cục** (chỉ `makeStore()`, tạo trong `StoreProvider` bằng `useState`); server component không đụng
  store; nạp dữ liệu ban đầu qua prop + dispatch lúc tạo store, **không `useEffect`**; dữ liệu theo route nạp lại có chặn `useRef`.
- Chỉ Redux Toolkit; thư mục theo tính năng, một file slice mỗi tính năng; state tối thiểu, chuẩn hoá bằng `createEntityAdapter`,
  giá trị suy ra bằng selector (`createSelector`, tên `selectXxx`).
- Reducer thuần, chỉ giá trị tuần tự hoá được; action là **sự kiện** (`cartItemAdded`), không setter; `status` kiểu máy trạng thái.
- Chỉ dùng `useAppSelector` / `useAppDispatch` / `useAppStore` (lint chặn hook gốc); thunk dùng `createAppAsyncThunk`.

## 4. Quy ước chung

- TypeScript strict; không `any`, không `as` ép kiểu để lấp lỗi, không `@ts-ignore` / `eslint-disable` để cho qua.
- Form: kiểm dữ liệu ở cả client (trải nghiệm) và server (an toàn); hiển thị lỗi cạnh ô nhập.
- Ảnh dùng `next/image` (có `width`/`height` hoặc `fill` + `sizes`); font dùng `next/font`; link nội bộ dùng `<Link>`.
- Ngày giờ, số, tiền: `Intl.DateTimeFormat` / `Intl.NumberFormat` (locale `vi-VN`), cẩn thận lệch hydrate giữa server và client.
- Không để `console.log`, code chết, TODO không chủ.

## 5. Tự soát trước khi báo xong

- [ ] `npm run check` (typecheck + lint `--max-warnings=0` + format) và `next build` qua; không thêm `eslint-disable`/`@ts-ignore`, không sửa cấu hình lint/tsconfig.
- [ ] SWR (nếu đụng): đạt `references/swr.md` mục 8. Redux (nếu đụng): đạt `references/redux.md` mục 7.
- [ ] UI dùng component shadcn đã có, màu ngữ nghĩa, không tự chế; JS trang trong ngân sách (`khung-du-an.md` bước 9).
- [ ] Không có `"use client"` thừa ở page/layout; client component chỉ nhận dữ liệu cần thiết.
- [ ] Không có `await` nối tiếp cho việc độc lập; không import qua barrel của thư viện lớn (lucide, lodash, MUI...).
- [ ] Không dùng `useEffect` để tính state dẫn xuất hoặc gọi lại dữ liệu đã có ở server.
- [ ] Server Action có xác thực + kiểm dữ liệu.
- [ ] Có trạng thái đang tải / lỗi / rỗng cho mỗi chỗ lấy dữ liệu.
- [ ] Không prop boolean mới chỉ để rẽ nhánh giao diện.

Review code người khác: báo lỗi dạng `file:dòng — quy tắc — sửa thế nào`, xếp theo ưu tiên bảng mục 2.

## 6. Khi giao DeepSeek (skill giao-deepseek)

Phase 0 (Claude tự làm) = `references/khung-du-an.md`; mục "Không được" của file đó chép vào mọi kế hoạch FE, lệnh `npm run check` là lệnh kiểm của mọi phase. DeepSeek **không đọc được skill này**. Ở vai DA, chép vào mục "Bối cảnh kỹ thuật"/"Không được làm" của kế hoạch những quy tắc áp cho việc đó (vd: "page.tsx là server component, chỉ `FilterBar` là client", "fetch user và orders bằng `Promise.all`"), và đưa danh sách mục 5 vào "Tiêu chí nghiệm thu". Khi nghiệm thu, soát diff theo mục 2–5.

## Nguồn

Gộp và Việt hoá từ Vercel `react-best-practices` và `composition-patterns` (MIT); SWR, Redux, khung dự án chắt lọc từ tài liệu
chính chủ và đã chạy thử — xem `NGUON.md`.

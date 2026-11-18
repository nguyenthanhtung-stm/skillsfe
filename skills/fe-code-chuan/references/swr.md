# SWR chuẩn production (dữ liệu server ở client — Next.js App Router)

Chắt lọc từ tài liệu chính chủ https://swr.vercel.app (đọc 2026-11-18, SWR 2.5): *With Next.js*, *Understanding SWR*, *Mutation*,
*Error Handling*. Không có skill SWR chính chủ (skill `swr` cũ trong vercel-plugin đã bị gỡ).

## 1. Phân vai dữ liệu (quyết định của dự án)

| Loại dữ liệu | Dùng |
|---|---|
| Đọc để hiển thị, không cần cập nhật trực tiếp | `fetch` trong **server component** — không SWR, không JS gửi xuống |
| Dữ liệu server ở client cần làm mới / tương tác (danh sách có lọc, bảng điều khiển, tìm kiếm) | **SWR** (`useSWR`, `useSWRInfinite`) |
| Ghi dữ liệu do người dùng bấm | **Server Action** hoặc `useSWRMutation` → làm mới key SWR liên quan |
| State toàn cục thuần client (đăng nhập, giỏ, cài đặt) | **Redux** (`redux.md`) — **không** chép dữ liệu SWR vào Redux |
| Bộ lọc, trang, tab | URL — key SWR dựng từ `searchParams` |

**Không dùng RTK Query** (dự án đã chốt SWR) — quy tắc `client-swr-dedup` trong `hieu-nang/` khớp với lựa chọn này.

## 2. Quy tắc Next.js [bắt buộc]

- Hook `useSWR`, `useSWRInfinite`, `useSWRMutation` chỉ ở **client component**.
- Trong server component chỉ được import `SWRConfig`, `preload`, `unstable_serialize`.
- Không tạo cache SWR dùng chung ở cấp module trên server.

## 3. Cấu hình chung — một fetcher, một chỗ

`src/lib/swr/fetcher.ts`
```ts
export class HttpError extends Error {
  constructor(public status: number, public info: unknown) { super(`HTTP ${status}`) }
}

export async function fetcher<T>(url: string): Promise<T> {
  const res = await fetch(url)
  if (!res.ok) throw new HttpError(res.status, await res.json().catch(() => null)) // fetch không tự ném khi 4xx/5xx
  return res.json() as Promise<T>
}
```

`src/app/SwrProvider.tsx`
```tsx
'use client'
import { SWRConfig } from 'swr'
import { fetcher, HttpError } from '@/lib/swr/fetcher'

export function SwrProvider({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher,
        // không thử lại lỗi do người dùng/quyền: 400, 401, 403, 404, 422
        onErrorRetry: (err, _key, _cfg, revalidate, { retryCount }) => {
          if (err instanceof HttpError && err.status < 500) return
          if (retryCount >= 3) return
          setTimeout(() => revalidate({ retryCount }), 2000 * 2 ** retryCount)
        },
        onError: (_err) => {
          // một chỗ duy nhất báo lỗi (toast / Sentry); 401 → chuyển trang đăng nhập
        },
      }}
    >
      {children}
    </SWRConfig>
  )
}
```
Bọc trong `app/layout.tsx` cùng `StoreProvider`. Fetcher toàn cục → các hook chỉ cần `useSWR(key)`.

## 4. Key

- **Một nguồn định nghĩa key** cho mỗi tài nguyên: `src/lib/swr/keys.ts` (`keys.orders(filter)` → `['/api/orders', filter]`).
  Mutation và revalidate dùng lại đúng hàm này — không gõ chuỗi URL rải rác.
- Key có tham số: dùng **mảng** `['/api/orders', { status, page }]` (fetcher nhận mảng hoặc tự ghép query).
- Gọi có điều kiện: truyền **`null`** làm key khi chưa đủ điều kiện (`useSWR(userId ? keys.user(userId) : null)`). Không bọc hook
  trong `if`.
- Phụ thuộc nhau: key sau dựng từ `data` của hook trước (`project ? keys.tasks(project.id) : null`).

## 5. Đọc dữ liệu

- Viết **hook theo tài nguyên** ở thư mục tính năng: `features/orders/useOrders.ts` trả `{ orders, isLoading, error }` có kiểu.
  Component không gọi `useSWR` trực tiếp với URL.
- `isLoading` (chưa có dữ liệu lần đầu) → `Skeleton`; `isValidating` (đang làm mới) → chỉ báo nhỏ, không xoá nội dung.
- **Chỉ lấy trường cần dùng** (`const { data } = useSWR(...)`) — SWR chỉ re-render theo trường component đọc.
- Tìm kiếm/lọc gõ liên tục: `keepPreviousData: true` để không nháy về rỗng.
- Luôn xử lý đủ 3 trạng thái: đang tải / lỗi (có nút thử lại = `mutate()`) / rỗng (`Empty`).
- Dữ liệu và lỗi có thể cùng tồn tại (lần làm mới sau lỗi) → vẫn hiện dữ liệu cũ kèm báo lỗi.
- Dữ liệu hiếm đổi: tắt bớt làm mới (`revalidateOnFocus: false`) hoặc dùng `useSWRImmutable`; dữ liệu cần trực tiếp:
  `refreshInterval` (đặt ở hook, không đặt toàn cục).
- Phân trang "xem thêm"/cuộn vô hạn: `useSWRInfinite`; phân trang có số trang: key chứa `page` từ URL.

## 6. Dữ liệu ban đầu từ server (hiện ngay, không gọi trùng)

Cách ổn định: page (server) lấy dữ liệu → truyền vào `SWRConfig` `fallback` theo key:
```tsx
// app/orders/page.tsx (server)
import { SWRConfig, unstable_serialize } from 'swr'
const orders = await getOrders(filter)
return (
  <SWRConfig value={{ fallback: { [unstable_serialize(keys.orders(filter))]: orders }, revalidateIfStale: false }}>
    <OrdersTable filter={filter} />
  </SWRConfig>
)
```
**Phải có `revalidateIfStale: false`**: đã đo thật — chỉ có `fallback` thì SWR vẫn gọi API lại ngay khi trang tải (gọi trùng).
Có nó thì lần đầu dùng dữ liệu server; key khác (đổi bộ lọc) chưa có dữ liệu vẫn tự gọi API bình thường; làm mới khi quay lại
tab vẫn hoạt động. Key là chuỗi thì không cần `unstable_serialize`.

(SWR ≥ 2.5 có thêm `preload` + `cacheData` trong server component cho phép fetch song song và stream — còn **thử nghiệm**,
chỉ dùng khi thầy đồng ý.)

## 7. Ghi dữ liệu

- Ưu tiên **Server Action** (xác thực + kiểm dữ liệu ở server), xong gọi `mutate(keys.xxx())` để làm mới danh sách
  (và `revalidatePath` cho phần server render).
- Gọi API REST từ client: `useSWRMutation(key, sendRequest)` → `trigger(arg)`; **khoá nút khi `isMutating`**; `trigger` ném
  lỗi → bọc `try/catch` hoặc dùng `onError`.
- Cập nhật lạc quan (thao tác cần cảm giác tức thì: tick, thích, sắp xếp):
  ```ts
  await mutate(updateTodo(todo), {
    optimisticData: (cur) => cur?.map((t) => (t.id === todo.id ? todo : t)) ?? [],
    rollbackOnError: true,
    populateCache: (updated, cur) => cur?.map((t) => (t.id === updated.id ? updated : t)) ?? [],
    revalidate: false, // phản hồi server đã là bản đúng
  })
  ```
- Làm mới nhiều key: `mutate((key) => Array.isArray(key) && key[0] === '/api/orders')` — kiểm kiểu key trước khi đọc.
- Đăng xuất: xoá cache `mutate(() => true, undefined, { revalidate: false })`.

## 8. Soát khi nghiệm thu

- [ ] Không `useSWR` trong server component; không `useEffect` + `fetch` tự viết cho dữ liệu server.
- [ ] Một fetcher chung ném lỗi khi `!res.ok`; key lấy từ `keys.ts`, không chuỗi URL rải rác.
- [ ] Có đủ trạng thái đang tải / lỗi / rỗng; `isValidating` không xoá nội dung đang hiện.
- [ ] Dữ liệu SWR không bị chép vào Redux hay `useState`.
- [ ] Sau mỗi thao tác ghi, đúng các key liên quan được làm mới; nút gửi khoá khi đang gửi.
- [ ] Trang cần hiện ngay có `fallback` từ server; không gọi API trùng lần đầu (xem tab Network).

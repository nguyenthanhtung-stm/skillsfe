# Redux chuẩn production (Redux Toolkit + Next.js App Router)

Chắt lọc từ tài liệu chính chủ Redux (đọc 2026-11-18): *Redux Toolkit Setup with Next.js*, *Redux Style Guide*,
*Usage with TypeScript* (Redux và RTK). Bậc **[A]** = bắt buộc, **[B]** = rất nên, **[C]** = chọn một cách và dùng thống nhất.

## 1. Khi nào dùng Redux

- Chỉ cho dữ liệu **toàn cục, dùng chung, thay đổi được**: người dùng đăng nhập, quyền, giỏ hàng, cài đặt giao diện, trạng thái
  nhiều màn hình cùng sửa. **[B]**
- **Không** đưa vào Redux:
  - Dữ liệu server đọc để hiển thị → lấy bằng `fetch` trong server component (async). Ở client cần cache/làm mới thì dùng
    **SWR** (`swr.md`). Dự án **không dùng RTK Query**.
  - Bộ lọc, tab, trang, id đang xem → **URL** (`searchParams`, `params`).
  - Ô nhập của form → state cục bộ / thư viện form; chỉ dispatch khi **gửi** **[C]**.
  - UI cục bộ (mở modal, hover) → `useState`.

## 2. Next.js: các quy tắc sống còn [A]

1. **Không có store toàn cục.** Không `export const store = configureStore(...)`. Chỉ có hàm `makeStore()`; server xử lý nhiều
   request song song, store chung = rò dữ liệu giữa người dùng.
2. **Server component không đọc/ghi store.** Mọi component tạo, cung cấp, đọc, ghi store là client component (`"use client"`).
3. Store tạo **một lần mỗi request/phiên trình duyệt** trong `StoreProvider` bằng `useState(makeStore)`.
4. Dữ liệu ban đầu từ server: page (server) fetch → truyền prop vào `StoreProvider` hoặc component client → dispatch khi khởi tạo
   store. **Không dùng `useEffect`** để nạp (chỉ chạy ở client → lệch hydrate, nháy).
5. **Dữ liệu theo route** (chi tiết sản phẩm, hồ sơ...): store ở layout tồn tại qua các lần chuyển trang → nạp lại trong
   component của route, chặn bằng `useRef` để chỉ chạy một lần mỗi lần vào route (mẫu ở mục 5).
6. Trang có dữ liệu riêng từng người đăng nhập: `export const dynamic = 'force-dynamic'`; sau khi sửa dữ liệu ở server:
   `revalidatePath` / `revalidateTag`.
7. Dữ liệu server ở client do **SWR** lo (`swr.md`), không chép vào slice.

## 3. Quy tắc viết Redux

**[A] bắt buộc**
- Không sửa state ngoài reducer (trong reducer viết kiểu "sửa trực tiếp" được vì có Immer).
- Reducer không có tác dụng phụ: không gọi API, không `Date.now()`, `Math.random()`, `crypto.randomUUID()` — tạo các giá trị đó ở
  `prepare` của action hoặc trong thunk.
- Chỉ giá trị **tuần tự hoá được** trong state và action: không Promise, Date, Map/Set, class, hàm. Ngày giờ lưu chuỗi ISO hoặc số.
- Một store duy nhất cho app, cung cấp qua `<Provider>`; logic không `import` store trực tiếp.

**[B] rất nên**
- Chỉ dùng **Redux Toolkit** (`configureStore`, `createSlice`, `createEntityAdapter`). Không viết `switch`/action type
  tay, không `connect`, không Immutable.js, không Redux-Saga/Observable.
- **Thư mục theo tính năng**, mỗi tính năng **một file slice** chứa state, reducer, action, selector:
  `lib/features/<ten>/<ten>Slice.ts`.
- Đặt nhiều logic nhất có thể **trong reducer** (thuần, dễ test). Reducer **giữ hình dạng state**: tránh `return action.payload`
  mù quáng (trừ dữ liệu kiểu form).
- Tên khoá state theo **dữ liệu**: `{ auth, cart, products }`, không `{ authReducer }`, không theo màn hình (`loginScreen`).
- Dữ liệu dạng danh sách/quan hệ → **chuẩn hoá** bằng `createEntityAdapter` (`{ ids, entities }`), không lồng mảng trong mảng.
- State **tối thiểu**, giá trị suy ra (tổng tiền, danh sách đã lọc) tính bằng **selector**, không lưu thêm.
- Coi reducer là **máy trạng thái**: trường `status: 'idle' | 'loading' | 'succeeded' | 'failed'`, bỏ qua chuyển trạng thái
  không hợp lệ.
- **Action là sự kiện, không phải setter**: `cartItemAdded`, `orderSubmitted` — không `setItems`, `SET_DATA`. Nhiều slice được
  phản ứng cùng một action (`extraReducers`). Tránh dispatch nhiều action liên tiếp cho một việc.
- Component đọc **càng hẹp càng tốt**: gọi `useAppSelector` nhiều lần với giá trị nhỏ, item con tự select theo id.
- TypeScript: suy kiểu từ store, **không** khai union action type tay.
- Bật Redux DevTools (mặc định của `configureStore`, tắt ở production nếu cần: `devTools: process.env.NODE_ENV !== 'production'`).

**[C] thống nhất**
- Action type dạng `domain/eventName` (mặc định của `createSlice`).
- Lấy dữ liệu server: **SWR** (không thuộc Redux); logic async khác: thunk (`createAppAsyncThunk`); luồng phản ứng dài: **listener middleware**.
- Đọc state qua **selector** đặt tên `selectXxx`; selector trả object/mảng mới thì **memo bằng `createSelector`**. Không cần
  selector cho từng trường lẻ.
- Logic phức tạp đưa ra khỏi component (thunk, listener, selector).

## 4. Cấu trúc thư mục

(Dự án tạo với `--src-dir` thì `app/` và `lib/` nằm trong `src/`; alias `@/*` trỏ `src/*`.)

```
app/
  layout.tsx            # bọc <StoreProvider> (hoặc chỉ ở route cần store)
  StoreProvider.tsx     # 'use client'
lib/
  store.ts              # makeStore + kiểu
  hooks.ts              # hook có kiểu
  createAppAsyncThunk.ts
  listenerMiddleware.ts # nếu dùng listener
  features/
    cart/cartSlice.ts
    auth/authSlice.ts
```

## 5. Khung code chuẩn (RTK 2.x, React-Redux 9.x)

`lib/store.ts`
```ts
import { combineSlices, configureStore } from '@reduxjs/toolkit'
import { cartSlice } from './features/cart/cartSlice'
import { listenerMiddleware } from './listenerMiddleware'

// combineSlices: slice tự khai `name` làm khoá; slice nạp lười dùng rootReducer.inject(...)
const rootReducer = combineSlices(cartSlice)
export type RootState = ReturnType<typeof rootReducer>

export const makeStore = (preloadedState?: Partial<RootState>) => {
  const store = configureStore({
    reducer: rootReducer,
    preloadedState,
    middleware: (getDefault) =>
      getDefault().prepend(listenerMiddleware.middleware),
  })
  return store
}

export type AppStore = ReturnType<typeof makeStore>
export type AppDispatch = AppStore['dispatch']
```

`lib/hooks.ts` — **chỉ dùng các hook này**, lint chặn `useDispatch`/`useSelector` gốc
```ts
import { useDispatch, useSelector, useStore } from 'react-redux'
import type { AppDispatch, AppStore, RootState } from './store'

export const useAppDispatch = useDispatch.withTypes<AppDispatch>()
export const useAppSelector = useSelector.withTypes<RootState>()
export const useAppStore = useStore.withTypes<AppStore>()
```

`lib/createAppAsyncThunk.ts`
```ts
import { createAsyncThunk } from '@reduxjs/toolkit'
import type { AppDispatch, RootState } from './store'

export const createAppAsyncThunk = createAsyncThunk.withTypes<{
  state: RootState
  dispatch: AppDispatch
  rejectValue: string
}>()
```

`lib/listenerMiddleware.ts`
```ts
import { createListenerMiddleware } from '@reduxjs/toolkit'
import type { AppDispatch, RootState } from './store'

export const listenerMiddleware = createListenerMiddleware()
export const startAppListening = listenerMiddleware.startListening.withTypes<RootState, AppDispatch>()
```

`app/StoreProvider.tsx`
```tsx
'use client'
import { useState } from 'react'
import { Provider } from 'react-redux'
import { makeStore, type AppStore, type RootState } from '@/lib/store'

export default function StoreProvider({
  preloadedState,
  children,
}: {
  preloadedState?: Partial<RootState>
  children: React.ReactNode
}) {
  const [store] = useState<AppStore>(() => makeStore(preloadedState))
  return <Provider store={store}>{children}</Provider>
}
```

Slice mẫu `lib/features/cart/cartSlice.ts`
```ts
import { createEntityAdapter, createSelector, createSlice, type PayloadAction } from '@reduxjs/toolkit'
import type { RootState } from '@/lib/store'

export interface CartItem { id: string; name: string; price: number; qty: number }

const itemsAdapter = createEntityAdapter<CartItem>()

interface CartState { items: ReturnType<typeof itemsAdapter.getInitialState>; status: 'idle' | 'submitting' | 'failed' }
const initialState: CartState = { items: itemsAdapter.getInitialState(), status: 'idle' }

export const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers: {
    cartItemAdded(state, action: PayloadAction<CartItem>) {        // sự kiện, không phải setter
      const existing = state.items.entities[action.payload.id]
      if (existing) existing.qty += action.payload.qty
      else itemsAdapter.addOne(state.items, action.payload)
    },
    cartItemRemoved(state, action: PayloadAction<string>) {
      itemsAdapter.removeOne(state.items, action.payload)
    },
  },
})

export const { cartItemAdded, cartItemRemoved } = cartSlice.actions

const itemSelectors = itemsAdapter.getSelectors((s: RootState) => s.cart.items)
export const selectCartItems = itemSelectors.selectAll
export const selectCartItemById = itemSelectors.selectById
export const selectCartTotal = createSelector([selectCartItems], (items) =>
  items.reduce((sum, i) => sum + i.price * i.qty, 0),
)
```

Nạp dữ liệu theo route (không dùng `useEffect`)
```tsx
'use client'
import { useRef } from 'react'
import { useAppStore } from '@/lib/hooks'
// productSlice: slice của tính năng sản phẩm, có action `productOpened(product)` (viết theo mẫu cartSlice)
import { productOpened, type Product } from '@/lib/features/product/productSlice'

export function ProductInit({ product }: { product: Product }) {
  const store = useAppStore()
  const done = useRef(false)
  if (!done.current) { store.dispatch(productOpened(product)); done.current = true }
  return null
}
```

## 6. Lint bắt buộc kèm Redux

Trong `eslint.config.mjs` (xem `khung-du-an.md`):
```js
{
  rules: {
    '@typescript-eslint/no-restricted-imports': ['error', {
      paths: [{ name: 'react-redux', importNames: ['useSelector', 'useDispatch', 'useStore'],
                message: 'Dùng useAppSelector / useAppDispatch / useAppStore từ @/lib/hooks.' }],
    }],
  },
},
// miễn cho chính hooks.ts (nơi tạo hook có kiểu), không có dòng này lint báo lỗi ngay file khung
{ files: ['**/lib/hooks.ts'], rules: { '@typescript-eslint/no-restricted-imports': 'off' } },
```

## 7. Soát khi nghiệm thu

- [ ] Không có biến `store` cấp module; `makeStore` chỉ gọi trong `StoreProvider` (và test).
- [ ] Không server component nào import `@/lib/hooks` hoặc slice để đọc state.
- [ ] Không `useEffect` dùng để nạp dữ liệu ban đầu vào store.
- [ ] Không `useSelector`/`useDispatch` gốc; selector trả mảng/object mới đều qua `createSelector`.
- [ ] State không chứa Date/Map/Set/class/hàm; reducer không gọi API, không `Date.now()`.
- [ ] Action đặt tên theo sự kiện; không dispatch dồn dập cho một thao tác.
- [ ] Dữ liệu server không bị chép tay vào slice khi SWR/fetch server đã lo.
- [ ] Kiểm tay: HTML từ server có dữ liệu store; chuyển giữa 2 route cùng loại (`/sp/1` → `/sp/2`) dữ liệu đúng;
      sửa → rời trang → quay lại vẫn đúng.
- [ ] Test reducer/selector thuần (không cần render) cho logic chính.

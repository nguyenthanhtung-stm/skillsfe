# Nguồn

- `references/hieu-nang/` — chép nguyên từ Vercel **react-best-practices**
  https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices (license: MIT, Vercel Engineering)
- `references/thanh-phan/` — chép nguyên từ Vercel **composition-patterns**
  https://github.com/vercel-labs/agent-skills/tree/main/skills/composition-patterns (license: MIT, Vercel)
- `SKILL.md` — tóm tắt, Việt hoá và bổ sung (ranh giới server/client, quy ước, danh sách tự soát, cách giao DeepSeek).

Lấy bản ngày 2026-11-18. Cập nhật: chép lại thư mục `rules/` từ hai link trên.

MIT License — Copyright (c) Vercel, Inc. Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files, to deal in the Software without restriction, subject to including this notice.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

## Bổ sung 2026-11-18
- `references/redux.md` — chắt lọc từ tài liệu chính chủ Redux: https://redux.js.org/usage/nextjs ,
  https://redux.js.org/style-guide/ , https://redux.js.org/usage/usage-with-typescript ,
  https://redux.js.org/toolkit/usage/usage-with-typescript (viết lại bằng tiếng Việt, không chép nguyên văn).
- `references/khung-du-an.md` — theo https://nextjs.org/docs/app/api-reference/config/eslint (bản 2026-10-15, Next 16:
  không còn `next lint`) + cấu hình bổ sung của skill.
- `references/swr.md` — chắt lọc từ https://swr.vercel.app (With Next.js, Understanding, Mutation, Error Handling; SWR 2.5),
  đã chạy thử; điểm `revalidateIfStale: false` cho fallback là kết quả đo thật, không có trong tài liệu.
- Khung shadcn theo skill chính chủ `shadcn` (thư mục `skills/shadcn` cùng repo này).

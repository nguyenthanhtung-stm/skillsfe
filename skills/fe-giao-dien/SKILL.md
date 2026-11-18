---
name: fe-giao-dien
description: Thiết kế và soát giao diện web có chủ đích — không "nhìn như AI làm", đúng chuẩn trải nghiệm (accessibility, focus, form, chuyển động, responsive, nội dung chữ). Dùng khi dựng màn hình/trang mới, làm lại giao diện, chọn màu/font/bố cục, hoặc review UI/UX, kiểm accessibility. Gộp từ Anthropic frontend-design + Vercel Web Interface Guidelines. Code React/Next.js chuẩn thì dùng thêm skill fe-code-chuan.
---

# FE giao diện có chủ đích

Hai phần: **A. Thiết kế** (đẹp, riêng, hợp nghiệp vụ) và **B. Sàn chất lượng** (không được dưới mức này). Làm mới thì đi A → B; chỉ review thì làm B.

## A. Thiết kế

### A1. Bám vào chủ đề
Xác định rõ: sản phẩm là gì, **ai dùng**, màn hình này **làm việc chính gì**. Không rõ thì tự đề xuất rồi hỏi thầy xác nhận. Nét riêng đến từ chính nghiệp vụ: màn hình cho kỹ thuật viên xét nghiệm khác hẳn trang giới thiệu đồ chơi. Dùng nội dung thật của nghiệp vụ, không lorem ipsum.

Phần mềm nghiệp vụ (quản lý, báo cáo, nhập liệu): "đẹp" = **rõ, nhanh, ít bấm** — mật độ thông tin hợp lý, bảng dễ quét, số căn phải dùng `tabular-nums`, trạng thái nổi bật bằng màu có nghĩa. Dành sự táo bạo cho trang giới thiệu/landing.

### A2. Hai lượt: lên phương án → soát → mới code
1. **Phương án ngắn** (token):
   - Màu: 4–6 mã hex có tên (nền, chữ, chính, phụ, trạng thái).
   - Chữ: 1–2 họ font và vai trò; thang cỡ chữ rõ ràng; dòng ≤ 80 ký tự. Font tiếng Việt phải đủ dấu (kiểm `ẫ ỡ ự ặ`).
   - Bố cục: 1 câu mô tả + khung ASCII; căn trái/giữa.
   - Nguyên tắc: 2–3 câu nói điều gì làm màn hình này khác.
2. **Tự soát phương án**: chỗ nào là lựa chọn mặc định mà trang nào cũng có → sửa, nói rõ đổi gì vì sao.
3. Code theo phương án; dựng token thành biến CSS / theme Tailwind, không rải mã màu khắp nơi. Dự án dùng **shadcn/ui**:
   đưa token vào các biến có sẵn trong `globals.css` (`--primary`, `--background`, `--radius`...) hoặc preset
   (`npx shadcn@latest apply <code> --only theme,font`), theo `design-system.md` của skill `shadcn`; giữ nguyên giao diện mặc định
   của shadcn = giao diện "ai cũng giống" → luôn đặt màu, font, bo góc riêng ở Phase 0. Dựng UI bằng component shadcn, không tự chế.
4. **Tự phê bình**: chụp màn hình (preview) xem lại ở desktop và mobile; bỏ bớt một thứ trang trí thừa.

### A3. Dấu hiệu "AI làm" — tránh trừ khi đề bài yêu cầu
- Nền kem ấm + serif to + điểm nhấn cam đất; hoặc nền gần đen + một màu xanh chuối/đỏ son.
- Bộ "thẻ SaaS": mọi thứ chặt vào thẻ bo góc giống hệt nhau, cùng một bóng xám mờ, gradient trang trí.
- Nhãn CHỮ HOA giãn chữ trên mọi tiêu đề; chuỗi `A · B · C`; thêm `→` vào mọi nút/link; font mono cho nhãn nhỏ.
- Tô đậm/nghiêng/đổi màu đúng một từ trong tiêu đề.
- Đánh số 01/02/03 khi nội dung không phải trình tự.
- Hiệu ứng trượt-hiện cho mọi section, hover cho mọi thẻ. Chỉ một khoảnh khắc chuyển động có dàn dựng; chuyển động đáp lại thao tác (mở, mở rộng, xác nhận) thì nên có.
- Hero mặc định "số to + nhãn nhỏ + gradient".

Táo bạo **ở một chỗ**, còn lại tiết chế. Đề bài/brand của thầy nói gì thì theo đúng như thế.

### A4. Chữ trong giao diện (tiếng Việt)
- Gọi theo ngôn ngữ người dùng, không theo cách hệ thống xây ("Thông báo", không phải "Cấu hình webhook").
- Nút nói đúng việc xảy ra: "Lưu thay đổi", không "Gửi"/"OK". Một hành động giữ một tên xuyên suốt: nút "Duyệt" → thông báo "Đã duyệt".
- Lỗi: nói rõ sai gì và sửa thế nào, không xin lỗi, không mơ hồ. Màn hình rỗng: chỉ việc nên làm tiếp.
- Viết hoa kiểu câu (chỉ chữ đầu), không Viết Hoa Mọi Chữ; dùng `…` không `...`; "Đang tải…", "Đang lưu…".
- Ngày giờ/số/tiền theo `vi-VN` qua `Intl.*` (`18/11/2026`, `1.250.000 ₫`).

## B. Sàn chất lượng (soát mọi màn hình)

- **Truy cập**: dùng thẻ đúng nghĩa (`<button>` cho hành động, `<a>`/`<Link>` cho điều hướng — không `<div onClick>`); nút chỉ có icon cần `aria-label`; ảnh có `alt`; ô nhập có `<label>`; tiêu đề `h1`–`h6` đúng thứ bậc; thông báo động có `aria-live="polite"`; tương phản chữ ≥ 4.5:1.
- **Focus**: mọi phần tử tương tác có viền focus thấy được (`:focus-visible`); không `outline: none` mà không thay thế; header dính không che phần tử đang focus.
- **Form**: `type`/`inputmode`/`autocomplete`/`name` đúng; không chặn dán; lỗi hiện cạnh ô và focus vào lỗi đầu tiên khi gửi; nút gửi chỉ khoá khi đang gửi (kèm spinner); cảnh báo khi rời trang còn dữ liệu chưa lưu.
- **Chuyển động**: tôn trọng `prefers-reduced-motion`; chỉ animate `transform`/`opacity`; không `transition: all`.
- **Nội dung**: chịu được chữ rất ngắn/rất dài (`truncate`, `line-clamp`, `break-words`, `min-w-0` cho con của flex); có trạng thái rỗng, đang tải, lỗi.
- **Ảnh**: có kích thước (chống nhảy bố cục); ảnh dưới màn hình `loading="lazy"`; ảnh chính đầu trang ưu tiên tải.
- **Hiệu năng**: danh sách > 50 dòng thì ảo hoá hoặc `content-visibility: auto`; không đọc layout (`getBoundingClientRect`...) trong render.
- **Điều hướng**: bộ lọc/tab/trang hiện tại nằm trên URL; hành động xoá/huỷ cần xác nhận hoặc cho hoàn tác.
- **Responsive & cảm ứng**: xem được từ 360px; vùng chạm ≥ 44px; không khoá zoom (`user-scalable=no`); modal có `overscroll-behavior: contain`.
- **Chế độ tối** (nếu có): `color-scheme: dark`, `<meta name="theme-color">`.

Đủ quy tắc gốc (tiếng Anh): `references/web-interface-guidelines.goc.md`. Có mạng thì lấy bản mới nhất: https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md

### Cách báo khi review
Nhóm theo file, mỗi dòng `file:dòng — vấn đề → sửa`, không dạo đầu; file đạt ghi `✓ đạt`.

## Khi giao DeepSeek (skill giao-deepseek)

DeepSeek không đọc được skill này. Ở vai DA: **Claude tự làm phần A** (phương án token + khung ASCII + một component mẫu ở Phase 0), ghi token và bố cục vào kế hoạch; đưa các mục của phần B liên quan vào "Tiêu chí nghiệm thu". Khi nghiệm thu: mở preview chụp desktop + mobile, soát theo phần B.

## Nguồn

Gộp và Việt hoá từ Anthropic `frontend-design` (Apache-2.0) và Vercel Web Interface Guidelines (MIT) — xem `NGUON.md`; bản gốc trong `references/`.

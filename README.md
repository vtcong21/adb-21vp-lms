# adb-21vp-lms
A learning management system.
## Notes
- Code frontend dùng 100% tiếng anh để dễ debug, mấy cái linh tinh của khánh t xóa sau.
- Tạo nhánh mới theo kiểu **gui-chau** để code.
## Database
### 1. setup
Xóa db hiện tại, chạy 3 file:
```
database.sql
dbPermisson.sql
trigger.sql
```
- Chú ý file database.sql đã có partition + view.
### 2. store procedure
- **Bắt buộc** chạy hết toàn bộ proc trong folder /resources/storePrcedures/. Chạy file bat (double click) trong /resources/storeProcedures/ hoặc chạy tay. 
- sp-chau Của Châu có vẻ có bug nên t vẫn để ngoài /resources/.
- Có sửa proc sp_All_GetUserProfile cho phù hợp code app.
- Có sửa proc sp_AD_INS_GetAnnualRevenueOfAnInstructor, lỗi typo.
### 3. data
Chú ý: data **rất** nặng, chưa final thì chỉ nên chạy tay những file cần thiết.

Có 2 cách chạy:
- Double click file bat /resources/seedData.
- Chạy từng file.

## App
- Tạo env trong folder client, server, có file env.example mẫu.
### 1. chạy server
```
npm i
npm run dev
```
- T viết api ko theo chuẩn W3C, tất cả các tham số truyền vào req.body giúp nha, phiên phiến thôi mng tui làm ko kịp :D
- Chưa auth nên tạm bỏ userId vào hẳn trong body luôn nha, về sau có token thì khỏi.
- Api có dạng: http://localhost:8000/api/...
### 2. chạy client
```
npm i
npm run dev
```
Có 2 cách để mở router mình cần:
- Login bằng acc đã đưa, nhớ bật backend.
- Theo VerifyRoute() (file App.jsx, dòng 41) thành router mình cần, ví dụ thay VerifyRoute() thành AdminRoute, chú ý lúc này mấy thông tin user không có (vì có đăng nhập đâu).

Khi code services, sửa tên folder cho hợp lí (dentist thay bằng instructor, guest thay bằng learner).
### Có thể code theo các bước sau nếu kbiet bắt đầu từ đâu:
  - Tạo page (folder pages).
  - Gắn route (folder routes).
  - Viết service để gọi api (folder services).
  - Trở lại page để code UI, gọi api, css bla bla bla... tạo component (folder components) để import vào page nếu cần.
# CHÚC MAY MẮN, CÓ GÌ HỎI TUI
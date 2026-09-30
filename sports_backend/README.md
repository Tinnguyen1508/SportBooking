# Sports backend

## Danh sách khu vực cho Flutter

API `GET /api/districts` trả về danh sách bản ghi từ `dbo.districts` với các trường `id`, `name`, `province_name`, được sắp xếp theo tỉnh/thành phố rồi quận/huyện.

## Tạo tài khoản mock để kiểm thử

Đảm bảo SQL Server đang chạy và cấu hình kết nối database trong `.env`, sau đó chạy tại thư mục `sports_backend`:

```bash
npm run seed:mock
```

Lệnh chỉ thêm tài khoản chưa có theo số điện thoại/email; chạy lại không tạo bản ghi trùng. Mật khẩu được lưu dưới dạng bcrypt hash.

| Vai trò | Số điện thoại | Email |
| --- | --- | --- |
| CUSTOMER | `0000000001` | `minhanh.customer@example.test` |
| CUSTOMER | `0000000002` | `quocbao.customer@example.test` |
| OWNER | `0000000003` | `ngoc.owner@example.test` |
| OWNER | `0000000004` | `hoangnam.owner@example.test` |

Mật khẩu cho các tài khoản được tạo: `Sport@123`. Có thể đăng nhập bằng số điện thoại hoặc email.

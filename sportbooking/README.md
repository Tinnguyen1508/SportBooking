# sportbooking

A new Flutter project.

## Chọn khu vực đặt sân

Trang khách hàng dùng `LocationSelectionModal` để tải tỉnh/thành phố và quận/huyện từ `GET http://localhost:5000/api/districts`. Trên Android Emulator, ứng dụng gọi backend qua `http://10.0.2.2:5000/api`.

Để kiểm thử modal với dữ liệu mẫu khi backend chưa chạy, truyền `useMockData: true` khi tạo widget. Mặc định ứng dụng gọi API thật.

Nút “Tìm sân gần vị trí của tôi” xin quyền vị trí khi sử dụng. Bấm “Áp dụng” trả về `district_id`, `province_name` hoặc cặp `lat`/`lng`; trang chủ dùng các giá trị này làm query parameters khi tải lại danh sách sân.

Trang chủ có dữ liệu mẫu dự phòng gồm 6 môn thể thao (bao gồm bóng rổ và bóng chuyền), 4 tiện ích và 2 sân. Dữ liệu này tự hiển thị khi API tương ứng chưa có, trả về danh sách rỗng hoặc không kết nối được; khi API trả dữ liệu thật, dữ liệu thật được ưu tiên.

Các lượt đặt thử được lưu trên thiết bị bằng SharedPreferences sau khi hoàn tất bước thanh toán. Khung giờ đã đặt sẽ chuyển đỏ theo đúng sân con và ngày, đồng thời chi tiết ngày/giờ được hiển thị trong mục “Lịch của tôi”. Đây là lưu trữ mock cục bộ; để đồng bộ giữa nhiều thiết bị cần API đặt sân và bảng booking phía backend.

Modal khu vực luôn hiển thị danh sách 63 tỉnh/thành theo bộ địa giới cũ để tương thích dữ liệu mẫu như Bình Định, đồng thời bổ sung tên tỉnh/thành khác có trong API. Nếu khu vực được chọn không có sân phù hợp, trang chủ hiển thị “Hiện tại không có sân”.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

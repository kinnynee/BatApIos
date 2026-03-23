# Court Booking IoT Server

Server Node.js cho hệ thống đặt sân IoT sử dụng Firebase làm database.

## Cài đặt

1. Cài đặt dependencies:
   ```
   npm install
   ```

2. Thiết lập Firebase:
   - Tạo dự án Firebase
   - Tải service account key và đặt tên `firebase-service-account.json`
   - Cập nhật `.env` với thông tin Firebase

3. Chạy server:
   ```
   npm start
   ```

## API Endpoints

### Authentication
- `POST /auth/login` - Đăng nhập
- `POST /auth/register` - Đăng ký
- `POST /auth/forgot-password` - Quên mật khẩu

### Bookings
- `POST /bookings` - Đặt sân
- `GET /bookings` - Lấy lịch sử đặt sân
- `PUT /bookings/:id` - Cập nhật đặt sân
- `DELETE /bookings/:id` - Hủy đặt sân

### Courts
- `GET /courts` - Lấy danh sách sân

## Database Schema

### Users
```
{
  uid: string,
  email: string,
  name: string,
  phone: string,
  createdAt: timestamp
}
```

### Bookings
```
{
  id: string,
  userId: string,
  courtId: string,
  date: string,
  time: string,
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled',
  createdAt: timestamp
}
```

### Courts
```
{
  id: string,
  name: string,
  type: string,
  location: string,
  available: boolean
}
```
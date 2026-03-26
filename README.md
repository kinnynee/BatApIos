# Firebase backend starter for iOS/Xcode

Day la bo khoi tao backend dung Firebase de ket noi voi app mobile iOS cho bai toan dat san.

## API backend

Chay server local:

```bash
npm start
```

Mac dinh server chay o:

```txt
http://localhost:3000
```

Kiem tra nhanh:

```bash
GET /health
```

### API co san

- `POST /api/auth/login`
- `POST /api/auth/sync-user`
- `GET /api/auth/profile/:uid`
- `GET /api/users`
- `GET /api/users/:id`
- `POST /api/users`
- `PATCH /api/users/:id`
- `GET /api/courts`
- `GET /api/courts/:id`
- `POST /api/courts`
- `PATCH /api/courts/:id`
- `GET /api/bookings`
- `GET /api/bookings/:id`
- `POST /api/bookings`
- `PATCH /api/bookings/:id`
- `GET /api/payments`
- `GET /api/payments/:id`
- `POST /api/payments`
- `PATCH /api/payments/:id`

### Login API cho Postman va Xcode

Neu ban muon backend tu dang nhap bang `email/password`, goi:

```json
POST /api/auth/login
{
  "email": "admin@qlscl.app",
  "password": "your-password"
}
```

Response thanh cong:

```json
{
  "success": true,
  "data": {
    "uid": "firebase_uid_thuc_te",
    "email": "admin@qlscl.app",
    "idToken": "firebase-id-token",
    "refreshToken": "firebase-refresh-token",
    "expiresIn": "3600",
    "registered": true,
    "profile": {
      "id": "firebase_uid_thuc_te",
      "role": "admin",
      "status": "active"
    }
  }
}
```

App iOS co the dua vao `data.profile.role` de mo giao dien admin hay user.

### Luong dang nhap cho Xcode

Sau khi user dang nhap bang Firebase Auth trong iOS, app lay `uid`, `email`, `displayName`, `phoneNumber`, `photoURL` roi goi:

```json
POST /api/auth/sync-user
{
  "uid": "firebase_uid_thuc_te",
  "fullName": "Nguyen Van B",
  "email": "nguyenvanb@gmail.com",
  "phone": "0912345678",
  "avatarUrl": ""
}
```

Server se:

- Tu dong tao user neu chua co
- Tu dong dat `role = user`
- Tu dong dat `status = active`
- Neu email nam trong bien moi truong `ADMIN_EMAILS`, role se la `admin`
- Neu tai khoan da ton tai va dang la `admin`, server giu nguyen role admin

Sau do Xcode goi:

```txt
GET /api/auth/profile/:uid
```

Neu response tra ve:

```json
{
  "success": true,
  "data": {
    "id": "firebase_uid_thuc_te",
    "role": "admin",
    "status": "active"
  }
}
```

thi app co the mo giao dien quan ly san cho admin. Neu `role = user` thi mo giao dien khach hang.

### Query filter ho tro

- `GET /api/users?role=admin&status=active`
- `GET /api/courts?courtType=vip&status=available`
- `GET /api/bookings?userId=user_001&bookingDate=2026-03-27`
- `GET /api/payments?bookingId=booking_001&paymentStatus=paid`

### Vi du tao court

```json
POST /api/courts
{
  "id": "court_vip_02",
  "name": "San VIP 02",
  "courtType": "vip",
  "surfaceType": "synthetic_grass",
  "pricePerHour": 550000,
  "capacity": 14,
  "status": "available",
  "description": "San danh cho khung gio cao diem.",
  "imageUrls": []
}
```

### Vi du tao booking

```json
POST /api/bookings
{
  "id": "booking_003",
  "userId": "user_001",
  "courtId": "court_vip_01",
  "bookingCode": "BK-20260326-003",
  "bookingDate": "2026-03-29",
  "startTime": "19:00",
  "endTime": "20:30",
  "durationHours": 1.5,
  "pricePerHour": 500000,
  "totalAmount": 750000,
  "bookingStatus": "pending",
  "paymentStatus": "unpaid",
  "note": "Dat san tu app iOS.",
  "createdBy": "user_001"
}
```

API `bookings` co kiem tra trung lich theo `courtId`, `bookingDate`, `startTime`, `endTime`. Neu bi trung khung gio, server tra ve `409`.

## 1. Muc tieu phien ban dau

- Quan ly nguoi dung theo 3 vai tro: `admin`, `staff`, `user`
- Quan ly san theo 2 loai: `vip`, `bth`
- Luu thong tin `bookings` de dat san
- Luu thong tin `payments` de theo doi thanh toan
- San sang cho app iOS goi Firestore va Firebase Auth

## 2. Cau truc Firestore

### Collection `users`

| Field | Type | Example |
| --- | --- | --- |
| `fullName` | string | `Le Minh User` |
| `email` | string | `user1@qlscl.app` |
| `phone` | string | `0901000003` |
| `role` | string | `admin`, `staff`, `user` |
| `status` | string | `active` |
| `avatarUrl` | string | `""` |
| `createdAt` | timestamp | auto seed |
| `updatedAt` | timestamp | auto seed |

Document ID nen dung chinh `uid` tu Firebase Auth khi len production.

### Collection `courts`

| Field | Type | Example |
| --- | --- | --- |
| `name` | string | `San VIP 01` |
| `courtType` | string | `vip`, `bth` |
| `surfaceType` | string | `synthetic_grass` |
| `pricePerHour` | number | `500000` |
| `capacity` | number | `14` |
| `status` | string | `available`, `maintenance` |
| `description` | string | text |
| `imageUrls` | array | `[]` |
| `createdAt` | timestamp | auto seed |
| `updatedAt` | timestamp | auto seed |

### Collection `bookings`

| Field | Type | Example |
| --- | --- | --- |
| `userId` | string | `user_001` |
| `courtId` | string | `court_vip_01` |
| `bookingCode` | string | `BK-20260326-001` |
| `bookingDate` | string | `2026-03-27` |
| `startTime` | string | `18:00` |
| `endTime` | string | `19:30` |
| `durationHours` | number | `1.5` |
| `pricePerHour` | number | `500000` |
| `totalAmount` | number | `750000` |
| `bookingStatus` | string | `pending`, `confirmed`, `cancelled`, `completed` |
| `paymentStatus` | string | `unpaid`, `pending`, `paid`, `refunded` |
| `note` | string | text |
| `createdBy` | string | `staff_001` |
| `createdAt` | timestamp | auto seed |
| `updatedAt` | timestamp | auto seed |

### Collection `payments`

| Field | Type | Example |
| --- | --- | --- |
| `bookingId` | string | `booking_001` |
| `userId` | string | `user_001` |
| `amount` | number | `750000` |
| `paymentMethod` | string | `cash`, `bank_transfer`, `momo`, `zalopay` |
| `paymentStatus` | string | `pending`, `paid`, `failed`, `refunded` |
| `transactionCode` | string | `PAY-20260326-001` |
| `paidAt` | timestamp or null | payment time |
| `createdAt` | timestamp | auto seed |
| `updatedAt` | timestamp | auto seed |

## 3. Thu tu thuc hien voi Firebase

1. Tao project tren Firebase Console.
2. Bat `Authentication` voi Email/Password cho mobile login.
3. Tao `Cloud Firestore` o production mode hoac test mode tuy giai doan.
4. Them file service account vao root project voi ten `serviceAccountKey.json`.
5. Copy file `.env.example` thanh `.env` va dien:

```env
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
```

6. Cai dependency:

```bash
npm install
```

7. Kiem tra du lieu seed:

```bash
npm run seed:check
```

8. Day du lieu len Firestore:

```bash
npm run seed
```

## 4. Goi tu iOS/Xcode

- Dang nhap bang Firebase Auth, lay `uid` de map voi document `users/{uid}`
- Lay danh sach san tu `courts`
- Tao don dat san moi trong `bookings`
- Sau khi thanh toan, cap nhat `payments` va dong bo `paymentStatus` cua `bookings`

## 5. Goi y buoc tiep theo

- Tao Cloud Functions de:
  - Tu dong sinh `bookingCode`
  - Chan trung lich dat san
  - Tu dong tao `payment` khi `booking` duoc xac nhan
- Tao API layer hoac repository cho iOS de dong nhat cach doc/ghi Firestore
- Them `fcmTokens` vao `users` de gui thong bao khi dat san thanh cong

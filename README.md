# Firebase backend starter for iOS/Xcode

Day la bo khoi tao backend dung Firebase de ket noi voi app mobile iOS cho bai toan dat san.

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

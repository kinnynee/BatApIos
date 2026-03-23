# BatApIos Technical Flow

## 1. Mục tiêu tài liệu

Tài liệu này mô tả:

- Luồng chạy hiện tại của ứng dụng `BatApIos`
- Nghiệp vụ nào đã được cài đặt thật
- Nghiệp vụ nào đang ở mức demo hoặc placeholder
- Vai trò của từng file trong project

Tài liệu phản ánh trạng thái code hiện có, không giả định thêm backend hoặc feature chưa được implement.

## 2. Tổng quan kiến trúc

Ứng dụng đang dùng:

- `UIKit`
- `Storyboard` với file chính là `Main.storyboard`
- `FirebaseCore`
- `FirebaseFirestore`

Kiến trúc hiện tại chưa tách rõ `service`, `repository`, `use case`, `coordinator`.
Phần lớn logic nằm trực tiếp trong `UIViewController`.

Có 2 nhóm màn hình chính:

- Nhóm có logic tương tác thật: `Auth`, `Booking`, `Payment`, `Staff`
- Nhóm placeholder dùng để mô tả nghiệp vụ tương lai: `Home`, `Discover`, `Checkout`, `Courts`, `Profile`, `Admin`, `About`, `Notifications`

## 3. Entry Point và vòng đời ứng dụng

### 3.1 App khởi động

File: `BatApIos/BatApIos/App/AppDelegate.swift`

Luồng khởi động:

1. Ứng dụng gọi `application(_:didFinishLaunchingWithOptions:)`
2. `FirebaseApp.configure()` được thực thi để khởi tạo Firebase
3. Ở chế độ `DEBUG`, app in thông tin cấu hình Firebase
4. App thử gọi `Firestore.firestore().collection("__health_check").document("ping").getDocument(...)`
5. Nếu kết nối Firestore được thì in log thành công, nếu không thì in log lỗi

Ý nghĩa:

- App đang xác minh việc cấu hình Firebase khi mở ứng dụng
- Chưa có điều hướng theo trạng thái đăng nhập
- Chưa có khôi phục session người dùng

### 3.2 Scene lifecycle

File: `BatApIos/BatApIos/App/SceneDelegate.swift`

Hiện trạng:

- `SceneDelegate` gần như để mặc định
- Không có custom window routing
- Không có deep link handling
- Không có auth gate hoặc role gate

Điều đó có nghĩa:

- Điều hướng đầu vào đang phụ thuộc trực tiếp vào `Main.storyboard`

## 4. Storyboard và điều hướng chính

File: `BatApIos/BatApIos/Main.storyboard/Base`

Storyboard này đang giữ:

- Login flow
- Forgot password
- Register
- Payment history
- Payment method
- Calendar
- Booking
- Tab bar chính
- Nhiều màn profile, admin, booking, discover

Điểm quan trọng:

- `Main.storyboard` hiện là trung tâm điều hướng UI
- Nhiều màn được mở bằng `instantiateViewController(withIdentifier:)`
- App chưa có coordinator riêng

## 5. Shared Layer

### 5.1 Base placeholder screen

File: `BatApIos/BatApIos/Shared/Base/StoryboardScreenViewController.swift`

Vai trò:

- Là base class cho các màn hình chưa có UI/nghiệp vụ hoàn chỉnh
- Nếu `view.subviews.isEmpty`, class này tự sinh giao diện placeholder

Luồng hoạt động:

1. `viewDidLoad()` gọi `configurePlaceholderUIIfNeeded()`
2. Nếu màn hình chưa có subview thật, controller tự dựng:
   - title
   - subtitle
   - danh sách highlight nghiệp vụ

Ý nghĩa:

- Các màn hình kế thừa class này mới có khung mô tả nghiệp vụ
- Chúng chưa có data flow thật

### 5.2 UIViewController extension

File: `BatApIos/BatApIos/Shared/Extensions/UIViewController+Extension.swift`

Chứa utility dùng chung:

- `showAlert(title:message:completion:)`
- `isValidEmail(_:)`
- `dismissKeyboardWhenTappedAround()`
- `topMostPresentedViewController()`

Ý nghĩa nghiệp vụ:

- Validation email đang dùng regex cục bộ
- Alert được gọi ở nhiều flow auth và staff
- Chưa có error handling layer tập trung

### 5.3 Firestore models

File: `BatApIos/BatApIos/Shared/Firebase/Model.swift`

Chứa model dữ liệu Firestore:

- `UserRole`
- `CourtType`
- `CourtStatus`
- `BookingStatus`
- `User`
- `Location`
- `Court`
- `Booking`

Ý nghĩa:

- Đây là lớp mô hình dữ liệu, chưa phải data access layer
- Chưa có code CRUD trực tiếp cho các model này
- Các model cho thấy định hướng schema dữ liệu của app

Lưu ý:

- File đang dùng `FirebaseFirestoreSwift`
- Nếu project chưa add module này, build sẽ fail

## 6. Flow nghiệp vụ hiện có

### 6.1 Luồng đăng nhập

File: `BatApIos/BatApIos/Features/Auth/LoginViewController.swift`

Mục tiêu:

- Nhập email và mật khẩu
- Bật/tắt hiển thị mật khẩu
- Điều hướng sang đăng ký

Luồng chi tiết:

1. `viewDidLoad()` gọi `setupUI()`
2. `setupUI()` đặt:
   - `passwordTextField.isSecureTextEntry = true`
   - icon mắt mặc định là `eye.slash`
3. Khi bấm nút mắt:
   - `isPasswordVisible` được toggle
   - chuyển `secureTextEntry`
   - đổi icon giữa `eye` và `eye.slash`
4. Khi bấm đăng nhập:
   - kiểm tra email và password không rỗng
   - kiểm tra email đúng format
   - nếu hợp lệ thì hiện alert thành công
5. Khi bấm đăng ký:
   - instantiate `RegisterVC` từ storyboard
   - present full screen

Hiện trạng nghiệp vụ:

- Chưa gọi `FirebaseAuth`
- Chưa query người dùng từ Firestore
- Chưa phân quyền theo `UserRole`
- Chưa điều hướng vào `MainTabBarVC` sau khi đăng nhập

Kết luận:

- Đây là login flow demo có validation form, chưa có xác thực thật

### 6.2 Luồng đăng ký

File: `BatApIos/BatApIos/Features/Auth/RegisterViewController.swift`

Mục tiêu:

- Tạo tài khoản từ form đăng ký

Luồng chi tiết:

1. `viewDidLoad()` bật `secureTextEntry` cho password và confirm password
2. Nút mắt điều khiển đồng thời cả 2 trường password
3. Khi bấm đăng ký:
   - kiểm tra đủ họ tên, email, password, confirm password
   - validate email
   - password tối thiểu 8 ký tự
   - confirm password phải trùng
   - nếu hợp lệ thì hiện alert thành công
   - sau đó `dismiss`

Hiện trạng nghiệp vụ:

- Chưa tạo user trong Firebase Auth
- Chưa ghi `User` vào Firestore
- Chưa kiểm tra email đã tồn tại

Kết luận:

- Mới là registration form validation cục bộ

### 6.3 Luồng quên mật khẩu

File: `BatApIos/BatApIos/Features/Auth/ForgotPasswordViewController.swift`

Luồng chi tiết:

1. User nhập email
2. Hệ thống kiểm tra email không rỗng
3. Kiểm tra format email
4. Nếu hợp lệ thì hiện alert báo đã gửi hướng dẫn khôi phục
5. Sau alert, màn hình tự `dismiss`

Hiện trạng:

- Chưa gửi email reset thật
- Chưa dùng Firebase Auth password reset

### 6.4 Luồng đặt lại mật khẩu

File: `BatApIos/BatApIos/Features/Auth/ResetPasswordViewController.swift`

Mục tiêu:

- Nhập mật khẩu mới và xác nhận mật khẩu mới

Luồng chi tiết:

1. `viewDidLoad()` bật `secureTextEntry`
2. Có 2 nút mắt riêng cho:
   - mật khẩu mới
   - xác nhận mật khẩu
3. Khi bấm reset:
   - kiểm tra 2 trường không rỗng
   - kiểm tra mật khẩu dài ít nhất 8 ký tự
   - kiểm tra confirm khớp
   - nếu hợp lệ thì hiện alert thành công
   - sau đó `dismiss` toàn bộ flow qua `rootViewController?.dismiss(...)`

Hiện trạng:

- Chưa verify reset token
- Chưa đổi mật khẩu thật ở backend hoặc Firebase

### 6.5 Luồng đổi mật khẩu

File: `BatApIos/BatApIos/Features/Auth/ChangePasswordViewController.swift`

Mục tiêu:

- Đổi mật khẩu khi người dùng đang ở trong app

Luồng chi tiết:

1. `viewDidLoad()` bật `secureTextEntry` cho 3 ô:
   - current
   - new
   - confirm
2. Bật dismiss keyboard khi tap ngoài
3. Khi bấm cập nhật:
   - kiểm tra đủ dữ liệu
   - new password ít nhất 8 ký tự
   - new password phải khác current password
   - confirm phải trùng
   - nếu hợp lệ thì báo thành công và `dismiss`

Hiện trạng:

- Chưa kiểm tra current password thật
- Chưa update mật khẩu trên server

### 6.6 Luồng đặt sân và tính giá

File: `BatApIos/BatApIos/Features/Booking/BookingViewController.swift`

Đây là màn có nghiệp vụ rõ nhất trong app hiện tại.

State chính:

- `courtTypeSegment`
- `priceLabel`
- `voucherTextField`
- `paymentButton`
- `isVoucherApplied`
- `currentTotalPrice`

Quy tắc giá:

- `double`: `150_000`
- `vip`: `220_000`
- `single`: `320_000`

Voucher hiện hỗ trợ:

- Mã hợp lệ duy nhất: `GIAM50K`
- Giảm: `50_000`

Luồng chi tiết:

1. `viewDidLoad()` gọi:
   - `configureUI()`
   - `updatePrice()`
2. `configureUI()`:
   - gán `UITextFieldDelegate`
   - add target cho segmented control
   - bật tap để ẩn keyboard
3. Khi đổi loại sân:
   - `courtTypeChanged(_:)` gọi `updatePrice()`
4. `updatePrice()`:
   - lấy loại sân hiện tại từ `selectedSegmentIndex`
   - tính giá gốc
   - nếu `isVoucherApplied = true` thì trừ `50_000`
   - không cho giá âm
   - cập nhật `currentTotalPrice`
   - format tiền theo locale `vi_VN`
5. `applyVoucherIfNeeded()` chạy khi user bấm Return trong text field:
   - trim input
   - uppercased mã
   - nếu rỗng thì bỏ áp dụng voucher
   - nếu đúng `GIAM50K` thì bật giảm giá
   - nếu sai thì báo lỗi
6. Khi bấm `Thanh Toán Ngay`:
   - kiểm tra `currentTotalPrice > 0`
   - instantiate `PaymentMethodViewController`
   - truyền `amountToPay`
   - nếu có navigation controller thì `push`
   - nếu không có thì `present full screen`

Kết luận:

- Màn này có business rule tương đối đầy đủ cho demo booking
- Tuy nhiên chưa lưu booking thật vào Firestore
- Chưa chọn sân theo dữ liệu backend
- Chưa có timeslot thật

### 6.7 Luồng chọn ngày

File: `BatApIos/BatApIos/Features/Booking/CalendarViewController.swift`

Mục tiêu:

- Cho user chọn nhanh một ngày đặt sân

Luồng chi tiết:

1. `viewDidLoad()` gọi:
   - `configureCollectionView()`
   - `reloadDates()`
2. `reloadDates()` sinh danh sách ngày từ `-3` đến `+10` quanh `selectedDate`
3. Collection view hiển thị các ngày bằng `CalendarDayCell`
4. Khi user chọn cell:
   - cập nhật `selectedDate`
   - reload lại collection view để đổi trạng thái selected
5. Nút back gọi `dismiss(animated: true)`

Hiện trạng:

- Chưa liên kết ngày chọn về booking flow
- Chưa lấy slot trống từ backend

### 6.8 Luồng chọn phương thức thanh toán

File: `BatApIos/BatApIos/Features/Payment/PaymentMethodViewController.swift`

State chính:

- `amountToPay`
- `bookingId`
- `selectedMethod`

Phương thức thanh toán hỗ trợ:

- ATM
- MoMo
- Chuyển khoản
- Visa
- ZaloPay

Luồng chi tiết:

1. Có helper `instantiate(amount:bookingId:)` để tạo controller từ storyboard và truyền dữ liệu
2. `viewDidLoad()` gọi:
   - `configureUI()`
   - `updateSelectionUI()`
3. `configureUI()`:
   - hiển thị số tiền
   - hiển thị booking id
   - set bo góc, border cho từng card thanh toán
   - add `UITapGestureRecognizer` cho từng card
4. Khi tap card:
   - `paymentViewTapped(_:)` đổi `selectedMethod`
   - gọi `updateSelectionUI()`
5. `updateSelectionUI()`:
   - đổi màu border
   - đổi nền
   - đổi icon checkmark
6. Khi bấm xác nhận thanh toán:
   - log phương thức và số tiền
   - cố instantiate màn `PaymentExecutionVC`
   - nếu thành công thì push qua màn tiếp theo

Hiện trạng:

- Chưa có lớp thực thi thanh toán thật
- Chưa tích hợp cổng thanh toán
- `PaymentExecutionVC` chưa thấy trong cấu trúc file hiện tại
- Đây là điểm có nguy cơ fail điều hướng nếu storyboard không có scene tương ứng

### 6.9 Luồng lịch sử thanh toán

Files:

- `BatApIos/BatApIos/Features/Payment/PaymentViewController.swift`
- `BatApIos/BatApIos/Features/Payment/OrderModel.swift`
- `BatApIos/BatApIos/Features/Payment/PaymentTableViewCell.swift`

Model sử dụng:

- `OrderStatus`
- `PaymentInfo`

Luồng chi tiết:

1. `PaymentViewController.viewDidLoad()`:
   - gán `tableView.delegate`
   - gán `tableView.dataSource`
   - gọi `setupMockData()`
   - filter mặc định theo `.success`
2. `setupMockData()` tạo danh sách thanh toán mock:
   - ảnh sản phẩm
   - tên sản phẩm
   - giá
   - trạng thái
3. Khi user đổi segmented control:
   - map `selectedSegmentIndex` sang `OrderStatus`
   - gọi `filterData(by:)`
4. `filterData(by:)`:
   - lọc `allPayments`
   - cập nhật `displayedPayments`
   - reload table view

Kết luận:

- Đây là màn demo order history
- Chưa load dữ liệu lịch sử booking hoặc payment thật

### 6.10 Luồng xác nhận đặt sân thành công

File: `BatApIos/BatApIos/Features/Booking/BookingSuccessViewController.swift`

Mục tiêu:

- Hiển thị trạng thái đặt sân thành công
- Điều hướng về lịch sử hoặc trang chủ

Luồng chi tiết:

1. Controller dùng `bookingCode` mặc định là `BK-882941`
2. `viewDidLoad()` dựng UI hoàn toàn bằng code
3. Màn hình hiển thị:
   - tiêu đề success
   - icon xác nhận
   - mã booking
   - vùng QR giả lập
   - nút xem lịch của tôi
   - nút quay về trang chủ
4. Nút `Xem lịch của tôi`:
   - instantiate `PaymentVC`
   - push qua lịch sử thanh toán
5. Nút `Quay về trang chủ`:
   - instantiate `HomeVC`
   - push về trang chủ

Hiện trạng:

- QR là biểu tượng placeholder
- Chưa có mã QR thật
- Chưa đọc booking thật theo mã

### 6.11 Luồng check-in của staff

File: `BatApIos/BatApIos/Features/Staff/StaffCheckInViewController.swift`

Mục tiêu:

- Giả lập check-in booking tại quầy

State chính:

- `isFlashEnabled`
- `manualCodeTextField`
- `bookingDetailsCard`

Luồng chi tiết:

1. `viewDidLoad()` gọi `configureUI()`
2. `configureUI()`:
   - hiển thị card booking
   - bo góc vùng preview camera
   - gán dữ liệu mẫu cho customer, court, time
   - set text field delegate
   - add action cho nút flash
   - bật dismiss keyboard
3. Khi bấm flash:
   - toggle `isFlashEnabled`
   - đổi icon nút flash
4. Khi nhập mã booking và bấm Return:
   - gọi `lookupBooking()`
5. `lookupBooking()`:
   - lấy mã nhập tay
   - nếu rỗng thì báo lỗi
   - nếu có dữ liệu thì hiển thị bookingDetailsCard
   - cập nhật tên khách, sân, giờ chơi bằng dữ liệu mock

Hiện trạng:

- Chưa có camera thật
- Chưa có scan QR
- Chưa lookup booking từ Firestore

## 7. Nhóm màn hình placeholder

Các file sau đang dùng `StoryboardScreenViewController`:

- `Features/Home/HomeViewController.swift`
- `Features/Home/DiscoverViewController.swift`
- `Features/Booking/CheckoutViewController.swift`
- `Features/Booking/CourtsViewController.swift`
- `Features/Booking/NewCourtBookingViewController.swift`
- `Features/Profile/ProfileViewController.swift`
- `Features/Profile/AboutViewController.swift`
- `Features/Profile/NotificationsViewController.swift`
- `Features/Admin/AdminDashboardViewController.swift`
- `Features/Admin/RevenueReportViewController.swift`
- `Features/Admin/SystemLogsViewController.swift`

Ý nghĩa:

- Các màn này đã có class riêng
- Đã mô tả rõ intended business purpose qua `screenTitleText`, `screenSubtitleText`, `screenHighlights`
- Nhưng chưa có:
  - data source thật
  - interaction logic thật
  - networking hoặc Firestore query
  - role-based routing

## 8. Vai trò từng file

### 8.1 App

- `BatApIos/BatApIos/App/AppDelegate.swift`
  - Khởi tạo Firebase
  - Debug Firestore health check

- `BatApIos/BatApIos/App/SceneDelegate.swift`
  - Scene lifecycle mặc định

- `BatApIos/BatApIos/App/GoogleService-Info.plist`
  - Cấu hình Firebase project

### 8.2 Shared

- `BatApIos/BatApIos/Shared/Base/StoryboardScreenViewController.swift`
  - Base class cho placeholder screen

- `BatApIos/BatApIos/Shared/Base/ViewController.swift`
  - Base controller chung cũ hoặc file nền

- `BatApIos/BatApIos/Shared/Extensions/UIViewController+Extension.swift`
  - Alert, validate email, dismiss keyboard

- `BatApIos/BatApIos/Shared/Firebase/Model.swift`
  - Schema dữ liệu Firestore

### 8.3 Auth

- `BatApIos/BatApIos/Features/Auth/LoginViewController.swift`
  - Login form demo

- `BatApIos/BatApIos/Features/Auth/RegisterViewController.swift`
  - Register form demo

- `BatApIos/BatApIos/Features/Auth/ForgotPasswordViewController.swift`
  - Quên mật khẩu demo

- `BatApIos/BatApIos/Features/Auth/ResetPasswordViewController.swift`
  - Đặt lại mật khẩu demo

- `BatApIos/BatApIos/Features/Auth/ChangePasswordViewController.swift`
  - Đổi mật khẩu trong app

### 8.4 Booking

- `BatApIos/BatApIos/Features/Booking/BookingViewController.swift`
  - Chọn loại sân, voucher, tổng tiền, sang payment method

- `BatApIos/BatApIos/Features/Booking/CalendarViewController.swift`
  - Chọn ngày qua collection view

- `BatApIos/BatApIos/Features/Booking/BookingSuccessViewController.swift`
  - Màn hình success sau booking

- `BatApIos/BatApIos/Features/Booking/CheckoutViewController.swift`
  - Placeholder checkout

- `BatApIos/BatApIos/Features/Booking/CourtsViewController.swift`
  - Placeholder danh sách sân

- `BatApIos/BatApIos/Features/Booking/NewCourtBookingViewController.swift`
  - Placeholder đặt sân nhanh

### 8.5 Payment

- `BatApIos/BatApIos/Features/Payment/OrderModel.swift`
  - Model dữ liệu payment history demo

- `BatApIos/BatApIos/Features/Payment/PaymentMethodViewController.swift`
  - Chọn phương thức thanh toán

- `BatApIos/BatApIos/Features/Payment/PaymentTableViewCell.swift`
  - Cell hiển thị item payment history

- `BatApIos/BatApIos/Features/Payment/PaymentViewController.swift`
  - Danh sách lịch sử thanh toán mock

### 8.6 Home/Profile/Admin/Staff

- `BatApIos/BatApIos/Features/Home/HomeViewController.swift`
  - Placeholder trang chủ

- `BatApIos/BatApIos/Features/Home/DiscoverViewController.swift`
  - Placeholder khám phá

- `BatApIos/BatApIos/Features/Profile/ProfileViewController.swift`
  - Placeholder hồ sơ

- `BatApIos/BatApIos/Features/Profile/AboutViewController.swift`
  - Placeholder giới thiệu

- `BatApIos/BatApIos/Features/Profile/NotificationsViewController.swift`
  - Placeholder thông báo

- `BatApIos/BatApIos/Features/Admin/AdminDashboardViewController.swift`
  - Placeholder dashboard admin

- `BatApIos/BatApIos/Features/Admin/RevenueReportViewController.swift`
  - Placeholder báo cáo doanh thu

- `BatApIos/BatApIos/Features/Admin/SystemLogsViewController.swift`
  - Placeholder log hệ thống

- `BatApIos/BatApIos/Features/Staff/StaffCheckInViewController.swift`
  - Flow check-in staff demo

## 9. Điều gì đã implement thật và điều gì chưa

### Đã implement ở mức logic cục bộ

- Validation email
- Validation password
- Toggle hiển thị mật khẩu
- Tính tiền theo loại sân
- Áp voucher demo
- Chuyển màn từ booking sang payment method
- Chọn payment method và đổi UI selected state
- Lọc lịch sử thanh toán mock
- Chọn ngày bằng collection view
- Check-in bằng mã nhập tay ở mức demo

### Chưa implement backend thật

- Đăng nhập thật
- Đăng ký thật
- Quên mật khẩu thật
- Đổi mật khẩu thật
- Tạo booking vào Firestore
- Lấy danh sách sân từ Firestore
- Lấy timeslot trống
- Thanh toán thật
- Check-in bằng QR thật
- Phân quyền `user/admin/staff`
- Điều hướng theo session đăng nhập

## 10. Rủi ro và điểm cần chú ý

### 10.1 Build issue hiện tại

`Shared/Firebase/Model.swift` đang import `FirebaseFirestoreSwift`.

Nếu dependency này chưa được cài vào project, build sẽ fail.

### 10.2 Payment flow chưa khép kín

`PaymentMethodViewController` đang cố mở `PaymentExecutionVC`.

Nếu storyboard chưa có scene này thì flow sẽ không đi tiếp được.

### 10.3 Auth flow chưa gắn với Firebase Auth

Các màn auth hiện chỉ dừng ở validation form và alert.

### 10.4 Nhiều màn chính vẫn là placeholder

Tab bar và nhiều màn quan trọng đã có controller riêng nhưng chưa có nghiệp vụ thật.

## 11. Kết luận

Trạng thái hiện tại của project phù hợp với một bản demo nghiệp vụ UIKit dùng storyboard:

- Có khung UI tương đối rộng
- Có một số flow người dùng đã chạy được ở mức local logic
- Chưa có data layer và authentication layer hoàn chỉnh
- Chưa có thanh toán thật và booking persistence thật

Nếu tiếp tục phát triển, thứ tự hợp lý là:

1. Tách auth thật bằng Firebase Auth
2. Tạo service layer cho Firestore
3. Lưu booking thật
4. Hoàn thiện payment flow
5. Thay placeholder screens bằng nghiệp vụ thật

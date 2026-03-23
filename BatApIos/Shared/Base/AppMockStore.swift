import Foundation

struct BookingRecord {
    let id: String
    let userId: String
    let courtName: String
    let bookingDate: Date
    let startTime: Date
    let endTime: Date
    var totalPrice: Double
    var status: BookingStatus
    var paymentMethodName: String?
}

struct AppNotificationItem {
    let id: String
    let userId: String
    let title: String
    let message: String
    let createdAt: Date
}

enum AppLogicError: LocalizedError {
    case emptyFields(String)
    case invalidCredentials
    case duplicatedEmail
    case userNotFound
    case wrongPassword
    case noActiveSession
    case bookingNotFound
    case bookingAlreadyPaid

    var errorDescription: String? {
        switch self {
        case .emptyFields(let message):
            return message
        case .invalidCredentials:
            return "Email hoặc mật khẩu không đúng."
        case .duplicatedEmail:
            return "Email này đã tồn tại."
        case .userNotFound:
            return "Không tìm thấy tài khoản tương ứng."
        case .wrongPassword:
            return "Mật khẩu hiện tại không chính xác."
        case .noActiveSession:
            return "Chưa có người dùng đăng nhập."
        case .bookingNotFound:
            return "Không tìm thấy booking cần xử lý."
        case .bookingAlreadyPaid:
            return "Booking này đã được thanh toán."
        }
    }
}

final class AppMockStore {
    static let shared = AppMockStore()

    private(set) var currentUser: User?
    private var users: [User] = []
    private var bookings: [BookingRecord] = []
    private var notifications: [AppNotificationItem] = []

    private init() {
        seedData()
    }

    func login(email: String, password: String) throws -> User {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let user = users.first(where: { $0.email.lowercased() == normalizedEmail && $0.password == password }) else {
            throw AppLogicError.invalidCredentials
        }
        currentUser = user
        appendSystemLog(title: "Đăng nhập", message: "\(user.username) đã đăng nhập vào hệ thống.")
        return user
    }

    func logout() {
        currentUser = nil
    }

    func register(name: String, email: String, password: String) throws -> User {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppLogicError.emptyFields("Vui lòng nhập đầy đủ thông tin.")
        }
        guard users.contains(where: { $0.email.lowercased() == normalizedEmail }) == false else {
            throw AppLogicError.duplicatedEmail
        }

        let newUser = User(
            id: UUID().uuidString,
            email: normalizedEmail,
            username: name.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            role: .user,
            walletBalance: 0,
            createdAt: Date(),
            updatedAt: Date()
        )

        users.append(newUser)
        appendNotification(
            userId: newUser.id ?? "",
            title: "Chào mừng",
            message: "Tài khoản \(newUser.username) đã được tạo thành công."
        )
        appendSystemLog(title: "Đăng ký", message: "Tạo tài khoản mới: \(newUser.email)")
        return newUser
    }

    func sendResetPassword(email: String) throws -> String {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let user = users.first(where: { $0.email.lowercased() == normalizedEmail }) else {
            throw AppLogicError.userNotFound
        }
        appendNotification(
            userId: user.id ?? "",
            title: "Yêu cầu khôi phục mật khẩu",
            message: "Yêu cầu khôi phục mật khẩu đã được ghi nhận cho \(user.email)."
        )
        appendSystemLog(title: "Quên mật khẩu", message: "Gửi yêu cầu khôi phục cho \(user.email)")
        return "Hướng dẫn khôi phục mật khẩu đã được gửi đến \(user.email)."
    }

    func resetPassword(email: String, newPassword: String) throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let index = users.firstIndex(where: { $0.email.lowercased() == normalizedEmail }) else {
            throw AppLogicError.userNotFound
        }
        users[index].password = newPassword
        users[index].updatedAt = Date()
        appendNotification(
            userId: users[index].id ?? "",
            title: "Đặt lại mật khẩu",
            message: "Mật khẩu của bạn đã được thay đổi."
        )
        appendSystemLog(title: "Reset mật khẩu", message: "Đã reset mật khẩu cho \(users[index].email)")
    }

    func changePassword(currentPassword: String, newPassword: String) throws {
        guard let user = currentUser, let index = users.firstIndex(where: { $0.id == user.id }) else {
            throw AppLogicError.noActiveSession
        }
        guard users[index].password == currentPassword else {
            throw AppLogicError.wrongPassword
        }
        users[index].password = newPassword
        users[index].updatedAt = Date()
        currentUser = users[index]
        appendNotification(
            userId: users[index].id ?? "",
            title: "Đổi mật khẩu thành công",
            message: "Mật khẩu tài khoản đã được cập nhật."
        )
        appendSystemLog(title: "Đổi mật khẩu", message: "Người dùng \(users[index].email) đã đổi mật khẩu.")
    }

    func createBooking(courtTypeName: String, totalPrice: Double) throws -> BookingRecord {
        guard let user = currentUser else {
            throw AppLogicError.noActiveSession
        }

        let now = Date()
        let bookingDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        let startTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: bookingDate) ?? bookingDate
        let endTime = Calendar.current.date(byAdding: .minute, value: 90, to: startTime) ?? startTime
        let booking = BookingRecord(
            id: Self.makeBookingCode(),
            userId: user.id ?? "",
            courtName: courtTypeName,
            bookingDate: bookingDate,
            startTime: startTime,
            endTime: endTime,
            totalPrice: totalPrice,
            status: .pending,
            paymentMethodName: nil
        )
        bookings.insert(booking, at: 0)
        appendNotification(
            userId: booking.userId,
            title: "Đã tạo booking",
            message: "Booking \(booking.id) cho \(booking.courtName) đang chờ thanh toán."
        )
        appendSystemLog(title: "Tạo booking", message: "Booking \(booking.id) với giá \(Int(totalPrice)) đ")
        return booking
    }

    func confirmPayment(for bookingId: String, methodName: String) throws -> BookingRecord {
        guard let index = bookings.firstIndex(where: { $0.id == bookingId }) else {
            throw AppLogicError.bookingNotFound
        }
        guard bookings[index].status != .fullyPaid else {
            throw AppLogicError.bookingAlreadyPaid
        }

        bookings[index].status = .fullyPaid
        bookings[index].paymentMethodName = methodName
        appendNotification(
            userId: bookings[index].userId,
            title: "Thanh toán thành công",
            message: "Booking \(bookingId) đã thanh toán qua \(methodName)."
        )
        appendSystemLog(title: "Thanh toán", message: "Booking \(bookingId) đã thanh toán qua \(methodName)")
        return bookings[index]
    }

    func paymentHistory() -> [PaymentInfo] {
        guard let user = currentUser else { return [] }
        return bookings
            .filter { $0.userId == user.id }
            .map {
                PaymentInfo(
                    productImage: nil,
                    productName: "\($0.courtName) • \($0.id)",
                    price: Self.currencyFormatter.string(from: NSNumber(value: $0.totalPrice)) ?? "0 đ",
                    status: Self.orderStatus(for: $0.status)
                )
            }
    }

    func latestBooking() -> BookingRecord? {
        guard let user = currentUser else { return nil }
        return bookings.first(where: { $0.userId == user.id })
    }

    func findBooking(code: String) -> BookingRecord? {
        bookings.first { $0.id.uppercased() == code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
    }

    func notificationsForCurrentUser() -> [AppNotificationItem] {
        guard let user = currentUser else { return [] }
        return notifications
            .filter { $0.userId == user.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func seedData() {
        let now = Date()
        let demoUsers = [
            User(id: UUID().uuidString, email: "user@batapp.vn", username: "Nguyen Van A", password: "12345678", role: .user, walletBalance: 250_000, createdAt: now, updatedAt: now),
            User(id: UUID().uuidString, email: "admin@batapp.vn", username: "Admin BatApp", password: "12345678", role: .admin, walletBalance: 0, createdAt: now, updatedAt: now),
            User(id: UUID().uuidString, email: "staff@batapp.vn", username: "Staff BatApp", password: "12345678", role: .staff, walletBalance: 0, createdAt: now, updatedAt: now)
        ]
        users = demoUsers
        currentUser = demoUsers[0]

        let booking = BookingRecord(
            id: Self.makeBookingCode(),
            userId: demoUsers[0].id ?? "",
            courtName: "Sân VIP 02",
            bookingDate: now,
            startTime: now,
            endTime: Calendar.current.date(byAdding: .minute, value: 90, to: now) ?? now,
            totalPrice: 220_000,
            status: .fullyPaid,
            paymentMethodName: "MoMo"
        )
        bookings = [booking]
        appendNotification(
            userId: booking.userId,
            title: "Chào mừng quay lại",
            message: "Bạn đang có 1 booking đã thanh toán và sẵn sàng check-in."
        )
        appendSystemLog(title: "Khởi tạo dữ liệu mẫu", message: "Đã nạp dữ liệu demo cho ứng dụng.")
    }

    private func appendNotification(userId: String, title: String, message: String) {
        notifications.insert(
            AppNotificationItem(
                id: UUID().uuidString,
                userId: userId,
                title: title,
                message: message,
                createdAt: Date()
            ),
            at: 0
        )
    }

    private func appendSystemLog(title: String, message: String) {
        notifications.insert(
            AppNotificationItem(
                id: UUID().uuidString,
                userId: "system-log",
                title: title,
                message: message,
                createdAt: Date()
            ),
            at: 0
        )
    }

    private static func makeBookingCode() -> String {
        "BK-\(Int.random(in: 100000...999999))"
    }

    private static func orderStatus(for status: BookingStatus) -> OrderStatus {
        switch status {
        case .fullyPaid, .active:
            return .success
        case .cancelled:
            return .cancelled
        default:
            return .pending
        }
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

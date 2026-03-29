import Foundation

struct AppStoreBookingRecord {
    let id: String
    let userId: String
    let courtName: String
    let bookingDate: Date
    let startTime: Date
    let endTime: Date
    var totalPrice: Double
    var status: BookingStatus
    var paymentMethodName: String?
    var courtNumber: Int? = nil
    var courtTypeName: String? = nil
    var voucherCode: String? = nil
    var discountAmount: Double = 0
}

struct CourtBookingDraft {
    let courtName: String
    let courtNumber: Int
    let courtTypeName: String
    let bookingDate: Date
    let dateDisplayText: String
    let timeDisplayText: String
    let startTime: Date
    let endTime: Date
    let voucherCode: String?
    let discountAmount: Double
    let totalPrice: Double
}

struct PromotionBanner {
    let title: String
    let subtitle: String
    let voucherCode: String
    let discountAmount: Double
}

struct AppStoreNotificationItem {
    let id: String
    let userId: String
    let title: String
    let message: String
    let createdAt: Date
}

enum AppStoreLogicError: LocalizedError {
    case emptyFields(String)
    case invalidCredentials
    case duplicatedEmail
    case userNotFound
    case wrongPassword
    case noActiveSession
    case bookingNotFound
    case bookingAlreadyPaid
    case bookingNotReadyForCheckIn
    case bookingAlreadyCheckedIn

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
        case .bookingNotReadyForCheckIn:
            return "Chỉ booking đã thanh toán mới có thể check-in."
        case .bookingAlreadyCheckedIn:
            return "Booking này đã được check-in trước đó."
        }
    }
}

final class AppStore {
    static let shared = AppStore()

    private(set) var currentUser: User?
    private var users: [User] = []
    private var bookings: [AppStoreBookingRecord] = []
    private var notifications: [AppStoreNotificationItem] = []
    private var courts: [Court] = []

    private init() {}

    func login(email: String, password: String) throws -> User {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let user = users.first(where: { $0.email.lowercased() == normalizedEmail && $0.password == password }) else {
            throw AppStoreLogicError.invalidCredentials
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
            throw AppStoreLogicError.emptyFields("Vui lòng nhập đầy đủ thông tin.")
        }
        guard users.contains(where: { $0.email.lowercased() == normalizedEmail }) == false else {
            throw AppStoreLogicError.duplicatedEmail
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
        currentUser = newUser
        return newUser
    }

    func sendResetPassword(email: String) throws -> String {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let user = users.first(where: { $0.email.lowercased() == normalizedEmail }) else {
            throw AppStoreLogicError.userNotFound
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
            throw AppStoreLogicError.userNotFound
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
            throw AppStoreLogicError.noActiveSession
        }
        guard users[index].password == currentPassword else {
            throw AppStoreLogicError.wrongPassword
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

    func createBooking(courtTypeName: String, totalPrice: Double) throws -> AppStoreBookingRecord {
        let now = Date()
        let bookingDate = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        let startTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: bookingDate) ?? bookingDate
        let endTime = Calendar.current.date(byAdding: .minute, value: 90, to: startTime) ?? startTime
        let draft = CourtBookingDraft(
            courtName: courtTypeName,
            courtNumber: 1,
            courtTypeName: courtTypeName,
            bookingDate: bookingDate,
            dateDisplayText: "",
            timeDisplayText: "",
            startTime: startTime,
            endTime: endTime,
            voucherCode: nil,
            discountAmount: 0,
            totalPrice: totalPrice
        )
        return try createBooking(from: draft)
    }

    func createBooking(from draft: CourtBookingDraft) throws -> AppStoreBookingRecord {
        guard let user = currentUser else {
            throw AppStoreLogicError.noActiveSession
        }
        let booking = AppStoreBookingRecord(
            id: Self.makeBookingCode(),
            userId: user.id ?? "",
            courtName: draft.courtName,
            bookingDate: draft.bookingDate,
            startTime: draft.startTime,
            endTime: draft.endTime,
            totalPrice: draft.totalPrice,
            status: .pending,
            paymentMethodName: nil,
            courtNumber: draft.courtNumber,
            courtTypeName: draft.courtTypeName,
            voucherCode: draft.voucherCode,
            discountAmount: draft.discountAmount
        )
        bookings.insert(booking, at: 0)
        appendNotification(
            userId: booking.userId,
            title: "Đã tạo booking",
            message: "Booking \(booking.id) cho \(booking.courtName) đang chờ thanh toán."
        )
        appendSystemLog(title: "Tạo booking", message: "Booking \(booking.id) với giá \(Int(draft.totalPrice)) đ")
        return booking
    }

    func confirmPayment(for bookingId: String, methodName: String) throws -> AppStoreBookingRecord {
        guard let index = bookings.firstIndex(where: { $0.id == bookingId }) else {
            throw AppStoreLogicError.bookingNotFound
        }
        guard bookings[index].status != .fullyPaid else {
            throw AppStoreLogicError.bookingAlreadyPaid
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
                    bookingId: $0.id,
                    productImage: nil,
                    productName: "\($0.courtName) • \($0.id)",
                    subtitle: "\(Self.scheduleText(for: $0))",
                    amountValue: $0.totalPrice,
                    price: Self.currencyFormatter.string(from: NSNumber(value: $0.totalPrice)) ?? "0 đ",
                    paymentMethod: $0.paymentMethodName ?? "Chưa thanh toán",
                    status: Self.orderStatus(for: $0.status)
                )
            }
    }

    func latestBooking() -> AppStoreBookingRecord? {
        guard let user = currentUser else { return nil }
        return bookings.first(where: { $0.userId == user.id })
    }

    func myBookings() -> [AppStoreBookingRecord] {
        guard let user = currentUser else { return [] }
        return bookings
            .filter { $0.userId == user.id }
            .sorted { lhs, rhs in
                if lhs.bookingDate == rhs.bookingDate {
                    return lhs.startTime > rhs.startTime
                }
                return lhs.bookingDate > rhs.bookingDate
            }
    }

    func findBooking(code: String) -> AppStoreBookingRecord? {
        bookings.first { $0.id.uppercased() == code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
    }

    func displayName(for userId: String) -> String {
        users.first(where: { $0.id == userId })?.username ?? "Khách vãng lai"
    }

    @discardableResult
    func checkInBooking(code: String) throws -> AppStoreBookingRecord {
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard let index = bookings.firstIndex(where: { $0.id.uppercased() == normalizedCode }) else {
            throw AppStoreLogicError.bookingNotFound
        }

        if bookings[index].status == .active {
            throw AppStoreLogicError.bookingAlreadyCheckedIn
        }

        guard bookings[index].status == .fullyPaid || bookings[index].status == .partiallyPaid else {
            throw AppStoreLogicError.bookingNotReadyForCheckIn
        }

        bookings[index].status = .active
        appendNotification(
            userId: bookings[index].userId,
            title: "Check-in thành công",
            message: "Booking \(bookings[index].id) đã được xác nhận check-in."
        )
        appendSystemLog(title: "Check-in", message: "Booking \(bookings[index].id) đã được staff xác nhận check-in.")
        return bookings[index]
    }

    func notificationsForCurrentUser() -> [AppStoreNotificationItem] {
        guard let user = currentUser else { return [] }
        return notifications
            .filter { $0.userId == user.id }
            .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - Admin Accessors

    func getAllBookings() -> [AppStoreBookingRecord] {
        return bookings.sorted { $0.bookingDate > $1.bookingDate }
    }

    func getAllUsers() -> [User] {
        return users.sorted { $0.username < $1.username }
    }

    func featuredCourts() -> [Court] {
        courts.filter { $0.status == .active }
    }

    func activePromotion() -> PromotionBanner? {
        availablePromotions().first
    }

    func availablePromotions() -> [PromotionBanner] {
        []
    }
    
    // MARK: - Court Store
    
    func getAllCourts() -> [Court] {
        return courts
    }
    
    func getCourtById(id: String) -> Court? {
        return courts.first(where: { $0.id == id })
    }
    
    func updateCourtStatus(id: String, status: CourtStatus) {
        if let index = courts.firstIndex(where: { $0.id == id }) {
            courts[index].status = status
            appendSystemLog(title: "Cập nhật sân", message: "Sân \(courts[index].name) được chuyển sang trạng thái \(status.rawValue).")
        }
    }

    func createCourt(name: String, type: CourtType, locationId: String, pricePerHour: Double, status: CourtStatus) {
        let newCourt = Court(
            id: Self.makeCourtCode(existingIDs: courts.compactMap(\.id)),
            name: name,
            type: type,
            locationId: locationId,
            pricePerHour: pricePerHour,
            status: status
        )
        courts.append(newCourt)
        appendSystemLog(title: "Tạo sân", message: "Đã tạo sân \(newCourt.name) với giá \(Int(pricePerHour)) đ/giờ.")
    }

    func updateCourt(id: String, name: String, type: CourtType, locationId: String, pricePerHour: Double, status: CourtStatus) {
        guard let index = courts.firstIndex(where: { $0.id == id }) else { return }

        courts[index].name = name
        courts[index].type = type
        courts[index].locationId = locationId
        courts[index].pricePerHour = pricePerHour
        courts[index].status = status

        appendSystemLog(title: "Sửa sân", message: "Đã cập nhật sân \(courts[index].name).")
    }

    func deleteCourt(id: String) {
        guard let index = courts.firstIndex(where: { $0.id == id }) else { return }
        let removedCourt = courts.remove(at: index)
        appendSystemLog(title: "Xóa sân", message: "Đã xóa sân \(removedCourt.name).")
    }

    func getSystemLogs() -> [AppStoreNotificationItem] {
        return notifications
            .filter { $0.userId == "system-log" }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func updateBookingStatus(id: String, status: BookingStatus) {
        if let index = bookings.firstIndex(where: { $0.id == id }) {
            bookings[index].status = status
            appendSystemLog(title: "Cập nhật Booking", message: "Booking \(id) đổi trạng thái sang \(status).")
        }
    }

    private func appendNotification(userId: String, title: String, message: String) {
        notifications.insert(
            AppStoreNotificationItem(
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
            AppStoreNotificationItem(
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

    private static func makeCourtCode(existingIDs: [String]) -> String {
        let usedNumbers = Set(
            existingIDs.compactMap { id -> Int? in
                guard id.hasPrefix("C") else { return nil }
                return Int(id.dropFirst())
            }
        )

        for number in 1...999 {
            if usedNumbers.contains(number) == false {
                return String(format: "C%02d", number)
            }
        }

        return "C\(Int.random(in: 1000...9999))"
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

    private static func scheduleText(for booking: AppStoreBookingRecord) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateFormatter.dateFormat = "dd/MM/yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "vi_VN")
        timeFormatter.dateFormat = "HH:mm"

        return "\(dateFormatter.string(from: booking.bookingDate)) • \(timeFormatter.string(from: booking.startTime)) - \(timeFormatter.string(from: booking.endTime))"
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

}

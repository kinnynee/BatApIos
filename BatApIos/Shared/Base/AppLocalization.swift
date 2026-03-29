import Foundation

enum AppLanguage: String {
    case vietnamese = "vi"
    case english = "en"

    var displayName: String {
        switch self {
        case .vietnamese:
            return "Tiếng Việt"
        case .english:
            return "English"
        }
    }
}

enum AppLocalizedKey: String {
    case homeTab
    case bookTab
    case historyTab
    case profileTab
    case profileTitle
    case bookingsTitle
    case pointsTitle
    case languageTitle
    case accountSettings
    case notifications
    case changePassword
    case about
    case logout
    case chooseLanguage
    case close
    case cancel

    case bookCourtTitle
    case confirmBooking
    case selectDate
    case selectTime
    case selectCourtType
    case voucherCode
    case enterVoucherCode
    case apply
    case paymentSummary
    case discount
    case total
    case courtPrice
    case hourSingular
    case hourPlural
    case missingCode
    case enterVoucherCodeMessage
    case success
    case invalid
    case error
    case unableToOpenPaymentScreen
    case unableToCreateBooking
    case noCourtsAvailable
    case unableToLoadCourtsFromBackend
    case invalidDate
    case invalidDateMessage
    case invalidTime
    case invalidTimeMessage
    case invalidTimeRange
    case invalidTimeRangeMessage
    case today
    case tomorrow
    case loadingCourts
    case createBookingLogTitle

    case bookingDetails
    case proceedToPayment
    case court
    case courtNumber
    case date
    case time
    case courtType
    case voucher
    case notApplied

    case checkout
    case continueToPayment
    case badmintonCourt
    case standardCourt
    case unableToCheckout
    case paymentHistoryTitle
    case noPaymentsInSection
    case tryOtherStatusOrCreateBooking
    case unableToLoadHistory
    case unableToOpenPaymentInfo
    case paymentInfoTitle
    case confirmPayment
    case cancelBooking
    case cancelBookingMessage
    case subtotal
    case currentMethod
    case currentBookingStatus
    case currentPaymentStatus
    case payableTotal
    case selectedMethod
    case backendBookingPaymentHelper
    case bookingCancelled
    case bookingPaid
    case paymentForAmount
    case paymentBooking
    case unableToPay
    case paymentCancelledLogTitle
    case cancelled
    case bookingAndPaymentCancelled
    case unableToCancel
    case paidStatus
    case pendingStatus
    case ongoingStatus
}

enum AppLocalization {
    static let languageDidChangeNotification = Notification.Name("batapp.language.didChange")
    private static let storageKey = "batapp.profile.language"

    private static let translations: [AppLocalizedKey: (vi: String, en: String)] = [
        .homeTab: ("Trang chủ", "Home"),
        .bookTab: ("Đặt sân", "Book"),
        .historyTab: ("Lịch sử", "History"),
        .profileTab: ("Cá nhân", "Profile"),
        .profileTitle: ("Trang cá nhân", "Profile"),
        .bookingsTitle: ("ĐẶT SÂN", "BOOKINGS"),
        .pointsTitle: ("ĐIỂM", "POINTS"),
        .languageTitle: ("Ngôn ngữ", "Language"),
        .accountSettings: ("Quản lý tài khoản", "Account Settings"),
        .notifications: ("Thông báo", "Notifications"),
        .changePassword: ("Đổi mật khẩu", "Change Password"),
        .about: ("Về ứng dụng", "About"),
        .logout: ("Đăng xuất", "Log Out"),
        .chooseLanguage: ("Chọn ngôn ngữ", "Choose Language"),
        .close: ("Đóng", "Close"),
        .cancel: ("Hủy", "Cancel"),

        .bookCourtTitle: ("Đặt sân", "Book a Court"),
        .confirmBooking: ("Xác nhận đặt", "Confirm Booking"),
        .selectDate: ("Chọn ngày", "Select Date"),
        .selectTime: ("Chọn thời gian", "Select Time"),
        .selectCourtType: ("Chọn loại sân", "Select Court Type"),
        .voucherCode: ("Mã giảm giá", "Voucher Code"),
        .enterVoucherCode: ("Nhập mã giảm giá", "Enter voucher code"),
        .apply: ("Áp dụng", "Apply"),
        .paymentSummary: ("Tóm tắt thanh toán", "Payment Summary"),
        .discount: ("Giảm giá", "Discount"),
        .total: ("Tổng cộng", "Total"),
        .courtPrice: ("Giá sân", "Court Price"),
        .hourSingular: ("giờ", "hour"),
        .hourPlural: ("giờ", "hours"),
        .missingCode: ("Thiếu mã", "Missing Code"),
        .enterVoucherCodeMessage: ("Vui lòng nhập mã giảm giá.", "Please enter a voucher code."),
        .success: ("Thành công", "Success"),
        .invalid: ("Không hợp lệ", "Invalid"),
        .error: ("Lỗi", "Error"),
        .unableToOpenPaymentScreen: ("Không thể mở màn hình thanh toán.", "Unable to open the payment screen."),
        .unableToCreateBooking: ("Không thể tạo booking", "Unable to Create Booking"),
        .noCourtsAvailable: ("Chưa có sân", "No Courts Available"),
        .unableToLoadCourtsFromBackend: ("Không tải được danh sách sân từ backend. Vui lòng thử lại.", "Unable to load courts from backend. Please try again."),
        .invalidDate: ("Ngày không hợp lệ", "Invalid Date"),
        .invalidDateMessage: ("Bạn không thể đặt sân cho ngày đã qua.", "You cannot book a court for a past date."),
        .invalidTime: ("Giờ không hợp lệ", "Invalid Time"),
        .invalidTimeMessage: ("Khung giờ đã chọn đã qua. Vui lòng chọn giờ khác.", "The selected time slot has already passed. Please choose another one."),
        .invalidTimeRange: ("Khung giờ không hợp lệ", "Invalid Time Range"),
        .invalidTimeRangeMessage: ("Giờ kết thúc phải lớn hơn giờ bắt đầu.", "End time must be later than start time."),
        .today: ("Hôm nay", "Today"),
        .tomorrow: ("Ngày mai", "Tomorrow"),
        .loadingCourts: ("Đang tải danh sách sân...", "Loading courts..."),
        .createBookingLogTitle: ("Tạo booking", "Create Booking"),

        .bookingDetails: ("Chi tiết đặt sân", "Booking Details"),
        .proceedToPayment: ("Tiến hành thanh toán", "Proceed to Payment"),
        .court: ("Sân đấu", "Court"),
        .courtNumber: ("Số sân", "Court No."),
        .date: ("Ngày", "Date"),
        .time: ("Giờ", "Time"),
        .courtType: ("Loại sân", "Court Type"),
        .voucher: ("Voucher", "Voucher"),
        .notApplied: ("Không áp dụng", "Not Applied"),

        .checkout: ("Thanh toán", "Checkout"),
        .continueToPayment: ("Tiếp tục thanh toán", "Continue to Payment"),
        .badmintonCourt: ("Sân cầu lông", "Badminton Court"),
        .standardCourt: ("Sân tiêu chuẩn", "Standard Court"),
        .unableToCheckout: ("Không thể checkout", "Unable to Checkout"),
        .paymentHistoryTitle: ("Lịch sử thanh toán", "Payment History"),
        .noPaymentsInSection: ("Chưa có đơn nào trong mục này.", "No payments in this section yet."),
        .tryOtherStatusOrCreateBooking: ("Hãy thử đổi trạng thái hoặc tạo booking mới.", "Try another status or create a new booking."),
        .unableToLoadHistory: ("Không tải được lịch sử", "Unable to Load History"),
        .unableToOpenPaymentInfo: ("Không thể mở thông tin thanh toán.", "Unable to open payment information."),
        .paymentInfoTitle: ("Thông tin thanh toán", "Payment Information"),
        .confirmPayment: ("Xác nhận thanh toán", "Confirm Payment"),
        .cancelBooking: ("Hủy booking", "Cancel Booking"),
        .cancelBookingMessage: ("Bạn muốn hủy booking và thanh toán này?", "Do you want to cancel this booking and payment?"),
        .subtotal: ("Tạm tính", "Subtotal"),
        .currentMethod: ("Phương thức hiện tại", "Current Method"),
        .currentBookingStatus: ("Trạng thái booking", "Booking Status"),
        .currentPaymentStatus: ("Trạng thái thanh toán", "Payment Status"),
        .payableTotal: ("Tổng thanh toán", "Total Payable"),
        .selectedMethod: ("Phương thức sẽ dùng", "Selected Method"),
        .backendBookingPaymentHelper: ("Booking được tạo từ backend. Xác nhận thanh toán sẽ cập nhật paymentStatus thật trên server.", "This booking was created from backend data. Confirming payment will update the real paymentStatus on the server."),
        .bookingCancelled: ("Booking đã hủy", "Booking Cancelled"),
        .bookingPaid: ("Booking đã thanh toán", "Booking Paid"),
        .paymentForAmount: ("Thanh toán %@", "Pay %@"),
        .paymentBooking: ("Thanh toán booking", "Booking Payment"),
        .unableToPay: ("Không thể thanh toán", "Unable to Pay"),
        .paymentCancelledLogTitle: ("Hủy thanh toán", "Cancel Payment"),
        .cancelled: ("Đã hủy", "Cancelled"),
        .bookingAndPaymentCancelled: ("Booking và thanh toán đã được chuyển sang trạng thái hủy.", "The booking and payment have been moved to cancelled status."),
        .unableToCancel: ("Không thể hủy", "Unable to Cancel"),
        .paidStatus: ("Đã thanh toán", "Paid"),
        .pendingStatus: ("Chờ thanh toán", "Pending"),
        .ongoingStatus: ("Đang diễn ra", "Ongoing")
    ]

    static var currentLanguage: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .english
    }

    static func setLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        NotificationCenter.default.post(name: languageDidChangeNotification, object: nil)
    }

    static func localized(vi: String, en: String) -> String {
        currentLanguage == .vietnamese ? vi : en
    }

    static func text(_ key: AppLocalizedKey) -> String {
        guard let translation = translations[key] else { return key.rawValue }
        return localized(vi: translation.vi, en: translation.en)
    }

    static func tabBarTitle(for index: Int) -> String {
        switch index {
        case 0:
            return text(.homeTab)
        case 1:
            return text(.bookTab)
        case 2:
            return text(.historyTab)
        case 3:
            return text(.profileTab)
        default:
            return ""
        }
    }
}

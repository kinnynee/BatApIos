import UIKit

final class PaymentMethodViewController: UIViewController {

    // MARK: - Instantiation Helpers
    static let storyboardName = "Main"
    static let storyboardID = "PaymentMethodVC"

    /// Tạo PaymentMethodViewController từ Storyboard và truyền sẵn dữ liệu cần thiết
    /// - Parameters:
    ///   - amount: Số tiền cần thanh toán
    ///   - bookingId: Mã đặt sân (nếu đã có sẵn). Nếu nil sẽ dùng giá trị mặc định trong VC
    /// - Returns: PaymentMethodViewController đã được cấu hình hoặc nil nếu không tìm thấy trong Storyboard
    static func instantiate(amount: Double, bookingId: String? = nil) -> PaymentMethodViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: storyboardID) as? PaymentMethodViewController else {
            return nil
        }
        vc.amountToPay = amount
        if let bookingId { vc.bookingId = bookingId }
        vc.openedFromPaymentHistory = true
        return vc
    }

    /// Cho phép cấu hình lại số tiền/mã đặt sân sau khi đã khởi tạo
    func configure(amount: Double, bookingId: String? = nil) {
        self.amountToPay = amount
        if let bookingId { self.bookingId = bookingId }
        openedFromPaymentHistory = true
        if isViewLoaded {
            amountLabel.text = Self.currencyFormatter.string(from: NSNumber(value: amount)) ?? "0 đ"
            bookingIdLabel.text = self.bookingId
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var bookingIdLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var methodsStackView: UIStackView!

    @IBOutlet private weak var checkATM: UIImageView!
    @IBOutlet private weak var checkMomo: UIImageView!
    @IBOutlet private weak var checkTransfer: UIImageView!
    @IBOutlet private weak var checkVisa: UIImageView!
    @IBOutlet private weak var checkZalo: UIImageView!

    @IBOutlet private weak var viewATM: UIView!
    @IBOutlet private weak var viewMomo: UIView!
    @IBOutlet private weak var viewTransfer: UIView!
    @IBOutlet private weak var viewVisa: UIView!
    @IBOutlet private weak var viewZalo: UIView!
    
    @IBOutlet private weak var confirmButton: UIButton!

    // MARK: - Public Variables (Biến để màn hình trước truyền dữ liệu vào)
    var amountToPay: Double = 0
    var bookingId: String = "BK-\(Int.random(in: 1000...9999))-2024" // Tạm thời tạo ID ngẫu nhiên

    // MARK: - State
    private enum PaymentMethod: CaseIterable {
        case atm
        case momo
        case transfer
        case visa
        case zalo
    }

    private var selectedMethod: PaymentMethod = .momo
    private let store = AppMockStore.shared
    private let bookingsService = BackendBookingsService.shared
    private let adminService = BackendAdminService.shared
    private let systemLogStore = SystemLogStore.shared
    private lazy var paymentInfoCard = makePaymentInfoCard()
    private let cancelBookingButton = UIButton(type: .system)
    private var currentBooking: BackendBookingRecord?
    private var openedFromPaymentHistory = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        attachBackActionIfNeeded()
        ensureConfirmButton()
        configureUI()
        updateSelectionUI()
        loadCurrentBookingIfNeeded()
    }

    // MARK: - Setup
    private func configureUI() {
        if let summary = store.paymentSummary(for: bookingId) {
            amountLabel.text = summary.totalText
            bookingIdLabel.text = summary.bookingID
            configurePaymentInfoCard(with: summary)
            confirmButton?.configuration?.title = "Thanh toán \(summary.totalText)"
        } else {
            amountLabel.text = Self.currencyFormatter.string(from: NSNumber(value: amountToPay)) ?? "0 đ"
            bookingIdLabel.text = bookingId
            configureBackendPaymentInfoCard()
        }
        configureConfirmButtonAppearance()

        if methodsStackView?.arrangedSubviews.contains(paymentInfoCard) == false {
            methodsStackView?.insertArrangedSubview(paymentInfoCard, at: 1)
        }

        configureCancelButton()
        if methodsStackView?.arrangedSubviews.contains(cancelBookingButton) == false {
            methodsStackView?.insertArrangedSubview(cancelBookingButton, at: 2)
        }

        let mappings: [(UIView, PaymentMethod)] = [
            (viewATM, .atm),
            (viewMomo, .momo),
            (viewTransfer, .transfer),
            (viewVisa, .visa),
            (viewZalo, .zalo)
        ]

        mappings.forEach { view, method in
            view.layer.cornerRadius = 16
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemGray5.cgColor
            
            // Cho phép user tương tác với view
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paymentViewTapped(_:))))
            view.tag = method.hashValue
        }
    }

    private func attachBackActionIfNeeded() {
        backButton?.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }

    private func ensureConfirmButton() {
        if confirmButton == nil {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            confirmButton = button

            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 24),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 16),
                button.heightAnchor.constraint(equalToConstant: 54)
            ])

            scrollView?.contentInset.bottom = 96
            scrollView?.verticalScrollIndicatorInsets.bottom = 96
        }

        confirmButton?.addTarget(self, action: #selector(confirmButtonPressed(_:)), for: .touchUpInside)
    }

    private func configureConfirmButtonAppearance() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = confirmButton?.configuration?.title ?? "Xác nhận thanh toán"
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = UIColor(
            red: 0.345,
            green: 0.933,
            blue: 0.553,
            alpha: 1
        )
        configuration.baseForegroundColor = UIColor(
            red: 0.063,
            green: 0.133,
            blue: 0.129,
            alpha: 1
        )
        confirmButton?.configuration = configuration
    }

    private func configureCancelButton() {
        var configuration = UIButton.Configuration.bordered()
        configuration.title = "Hủy booking"
        configuration.cornerStyle = .large
        configuration.baseForegroundColor = .systemRed
        cancelBookingButton.configuration = configuration
        cancelBookingButton.addTarget(self, action: #selector(cancelBookingTapped), for: .touchUpInside)
    }

    private func makePaymentInfoCard() -> UIStackView {
        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 12
        card.backgroundColor = .secondarySystemBackground
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        return card
    }

    private func configurePaymentInfoCard(with summary: PaymentSummary) {
        paymentInfoCard.arrangedSubviews.forEach { view in
            paymentInfoCard.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.text = "Thông tin thanh toán"

        let courtLabel = UILabel()
        courtLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        courtLabel.text = summary.courtName

        let scheduleLabel = UILabel()
        scheduleLabel.font = .systemFont(ofSize: 13)
        scheduleLabel.textColor = .secondaryLabel
        scheduleLabel.numberOfLines = 0
        scheduleLabel.text = "\(summary.bookingID) • \(summary.scheduleText)"

        let statusBadge = UILabel()
        statusBadge.font = .systemFont(ofSize: 12, weight: .bold)
        statusBadge.textColor = summary.status.tintColor
        statusBadge.text = summary.status.title.uppercased()

        paymentInfoCard.addArrangedSubview(titleLabel)
        paymentInfoCard.addArrangedSubview(courtLabel)
        paymentInfoCard.addArrangedSubview(scheduleLabel)
        paymentInfoCard.addArrangedSubview(statusBadge)
        paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Tạm tính", value: summary.subtotalText))
        paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Giảm giá", value: summary.discountText))
        paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Tổng thanh toán", value: summary.totalText, emphasize: true))
        paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Phương thức hiện tại", value: summary.paymentMethodText))
    }

    private func configureBackendPaymentInfoCard() {
        paymentInfoCard.arrangedSubviews.forEach { view in
            paymentInfoCard.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.text = "Thông tin thanh toán"

        let bookingLabel = UILabel()
        bookingLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        bookingLabel.text = currentBooking?.courtName.isEmpty == false ? currentBooking?.courtName : "Booking #\(bookingId)"

        let amountText = Self.currencyFormatter.string(from: NSNumber(value: amountToPay)) ?? "0 đ"
        let helperLabel = UILabel()
        helperLabel.font = .systemFont(ofSize: 13)
        helperLabel.textColor = .secondaryLabel
        helperLabel.numberOfLines = 0
        if let currentBooking {
            helperLabel.text = "\(currentBooking.bookingCode) • \(currentBooking.bookingDate) • \(currentBooking.startTime)-\(currentBooking.endTime)"
        } else {
            helperLabel.text = "Booking được tạo từ backend. Xác nhận thanh toán sẽ cập nhật paymentStatus thật trên server."
        }

        paymentInfoCard.addArrangedSubview(titleLabel)
        paymentInfoCard.addArrangedSubview(bookingLabel)
        paymentInfoCard.addArrangedSubview(helperLabel)
        if let currentBooking {
            paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Trạng thái booking", value: normalizedBookingStatus(currentBooking.bookingStatus)))
            paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Trạng thái thanh toán", value: normalizedPaymentStatus(currentBooking.paymentStatus)))
        }
        paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Tổng thanh toán", value: amountText, emphasize: true))
        paymentInfoCard.addArrangedSubview(makeInfoRow(title: "Phương thức sẽ dùng", value: displayName(for: selectedMethod)))
    }

    private func makeInfoRow(title: String, value: String, emphasize: Bool = false) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13, weight: emphasize ? .semibold : .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: emphasize ? 16 : 13, weight: emphasize ? .bold : .semibold)
        valueLabel.textColor = emphasize ? .label : .secondaryLabel
        valueLabel.text = value
        valueLabel.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    // MARK: - Actions
    @objc private func paymentViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch view.tag {
        case PaymentMethod.atm.hashValue:
            selectedMethod = .atm
        case PaymentMethod.transfer.hashValue:
            selectedMethod = .transfer
        case PaymentMethod.visa.hashValue:
            selectedMethod = .visa
        case PaymentMethod.zalo.hashValue:
            selectedMethod = .zalo
        default:
            selectedMethod = .momo
        }

        updateSelectionUI()
    }

    @objc private func backButtonTapped() {
        handleBackNavigation()
    }

    @objc private func cancelBookingTapped() {
        let alert = UIAlertController(
            title: "Hủy booking",
            message: "Bạn muốn hủy booking và thanh toán này?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        alert.addAction(UIAlertAction(title: "Hủy booking", style: .destructive, handler: { [weak self] _ in
            self?.performCancellation()
        }))
        present(alert, animated: true)
    }

    @objc private func confirmButtonPressed(_ sender: UIButton) {
        confirmPaymentTapped(sender)
    }

    @IBAction private func confirmPaymentTapped(_ sender: UIButton) {
        if store.paymentSummary(for: bookingId) != nil {
            do {
                let booking = try store.confirmPayment(for: bookingId, methodName: displayName(for: selectedMethod))
                let successViewController = BookingSuccessViewController()
                successViewController.bookingCode = booking.id
                navigationController?.pushViewController(successViewController, animated: true)
            } catch {
                let alert = UIAlertController(title: "Không thể thanh toán", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Đóng", style: .default))
                present(alert, animated: true)
            }
            return
        }

        confirmButton?.isEnabled = false
        confirmButton?.configuration?.showsActivityIndicator = true

        Task { [weak self] in
            guard let self else { return }

            do {
                let updatedBooking = try await self.confirmBackendPayment()

                await MainActor.run {
                    self.systemLogStore.append(
                        title: "Thanh toán booking",
                        message: "Khách đã thanh toán booking \(updatedBooking.bookingCode) bằng \(self.displayName(for: self.selectedMethod)).",
                        source: "payment"
                    )
                    self.confirmButton?.isEnabled = true
                    self.confirmButton?.configuration?.showsActivityIndicator = false

                    let successViewController = BookingSuccessViewController()
                    successViewController.bookingCode = updatedBooking.id
                    self.navigationController?.pushViewController(successViewController, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.confirmButton?.isEnabled = true
                    self.confirmButton?.configuration?.showsActivityIndicator = false

                    let alert = UIAlertController(title: "Không thể thanh toán", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Đóng", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func confirmBackendPayment() async throws -> BackendBookingRecord {
        let confirmerId = BackendAuthService.shared.restorePersistedUser()?.id ?? "user"

        if let booking = currentBooking {
            if let paymentRecord = try await findPaymentRecord(for: booking) {
                _ = try await adminService.confirmPayment(paymentId: paymentRecord.id, confirmedBy: confirmerId)

                let refreshedBookings = try await bookingsService.fetchBookings(userId: booking.userId)
                if let refreshed = refreshedBookings.first(where: {
                    $0.id.caseInsensitiveCompare(booking.id) == .orderedSame ||
                    $0.bookingCode.caseInsensitiveCompare(booking.bookingCode) == .orderedSame
                }) {
                    return refreshed
                }
            }
        }

        return try await bookingsService.updateBookingStatus(
            bookingId: bookingId,
            bookingStatus: "Fully Paid",
            paymentStatus: "Paid"
        )
    }

    private func findPaymentRecord(for booking: BackendBookingRecord) async throws -> BackendAdminPayment? {
        let directMatches = try await adminService.fetchPayments(bookingId: booking.id)
        if let directMatch = directMatches.first(where: {
            $0.bookingId.caseInsensitiveCompare(booking.id) == .orderedSame ||
            $0.bookingId.caseInsensitiveCompare(booking.bookingCode) == .orderedSame
        }) {
            return directMatch
        }

        let codeMatches = try await adminService.fetchPayments(bookingId: booking.bookingCode)
        return codeMatches.first
    }

    // MARK: - UI Updates
    private func updateSelectionUI() {
        let configurations: [(PaymentMethod, UIView, UIImageView)] = [
            (.atm, viewATM, checkATM),
            (.momo, viewMomo, checkMomo),
            (.transfer, viewTransfer, checkTransfer),
            (.visa, viewVisa, checkVisa),
            (.zalo, viewZalo, checkZalo)
        ]

        configurations.forEach { method, view, checkmark in
            let isSelected = method == selectedMethod
            view.layer.borderColor = isSelected ? UIColor.systemMint.cgColor : UIColor.systemGray5.cgColor
            view.backgroundColor = isSelected ? UIColor.systemMint.withAlphaComponent(0.08) : .systemBackground
            checkmark.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            checkmark.tintColor = isSelected ? .systemMint : .systemGray3
        }

        if store.paymentSummary(for: bookingId) == nil {
            configureBackendPaymentInfoCard()
            updateActionButtons()
        }
    }

    private func loadCurrentBookingIfNeeded() {
        guard store.paymentSummary(for: bookingId) == nil else {
            cancelBookingButton.isHidden = true
            return
        }

        Task { [weak self] in
            guard let self else { return }
            let userId = BackendAuthService.shared.restorePersistedUser()?.id
            guard let userId, !userId.isEmpty else { return }

            do {
                let bookings = try await bookingsService.fetchBookings(userId: userId)
                let booking = bookings.first {
                    $0.id.caseInsensitiveCompare(self.bookingId) == .orderedSame ||
                    $0.bookingCode.caseInsensitiveCompare(self.bookingId) == .orderedSame
                }

                await MainActor.run {
                    self.currentBooking = booking
                    if let booking {
                        self.amountToPay = booking.totalAmount
                        self.amountLabel.text = Self.currencyFormatter.string(from: NSNumber(value: booking.totalAmount)) ?? "0 đ"
                        self.bookingIdLabel.text = booking.bookingCode
                    }
                    self.configureBackendPaymentInfoCard()
                    self.updateActionButtons()
                }
            } catch {
                await MainActor.run {
                    self.updateActionButtons()
                }
            }
        }
    }

    private func updateActionButtons() {
        let isCancelled = currentBooking?.bookingStatus.caseInsensitiveCompare("cancelled") == .orderedSame ||
            currentBooking?.paymentStatus.caseInsensitiveCompare("cancelled") == .orderedSame
        let isPaid = currentBooking?.paymentStatus.caseInsensitiveCompare("paid") == .orderedSame

        let canCancel = openedFromPaymentHistory && !isCancelled && !isPaid && store.paymentSummary(for: bookingId) == nil
        let canConfirm = !isCancelled && !isPaid

        cancelBookingButton.isHidden = !canCancel
        confirmButton?.isHidden = openedFromPaymentHistory && !canConfirm
        confirmButton?.isEnabled = canConfirm

        if isCancelled {
            confirmButton?.configuration?.title = "Booking đã hủy"
        } else if isPaid {
            confirmButton?.configuration?.title = "Booking đã thanh toán"
        } else {
            let amountText = Self.currencyFormatter.string(from: NSNumber(value: amountToPay)) ?? "0 đ"
            confirmButton?.configuration?.title = "Thanh toán \(amountText)"
        }
    }

    private func performCancellation() {
        cancelBookingButton.isEnabled = false

        Task { [weak self] in
            guard let self else { return }
            do {
                let updatedBooking = try await bookingsService.cancelBooking(bookingId: bookingId)
                await MainActor.run {
                    self.currentBooking = updatedBooking
                    self.cancelBookingButton.isEnabled = true
                    self.configureBackendPaymentInfoCard()
                    self.updateActionButtons()
                    self.systemLogStore.append(
                        title: "Hủy thanh toán",
                        message: "Khách đã hủy booking \(updatedBooking.bookingCode) từ màn thông tin thanh toán.",
                        source: "payment"
                    )
                    self.showAlert(title: "Đã hủy", message: "Booking và thanh toán đã được chuyển sang trạng thái hủy.")
                }
            } catch {
                await MainActor.run {
                    self.cancelBookingButton.isEnabled = true
                    self.showAlert(title: "Không thể hủy", message: error.localizedDescription)
                }
            }
        }
    }

    private func normalizedBookingStatus(_ value: String) -> String {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "pending":
            return "Chờ thanh toán"
        case "fully paid", "confirmed":
            return "Đã thanh toán"
        case "active":
            return "Đang diễn ra"
        case "cancelled":
            return "Đã hủy"
        default:
            return value
        }
    }

    private func normalizedPaymentStatus(_ value: String) -> String {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "paid":
            return "Đã thanh toán"
        case "pending":
            return "Chờ thanh toán"
        case "cancelled":
            return "Đã hủy"
        default:
            return value
        }
    }
    
    // MARK: - Formatters
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private func displayName(for method: PaymentMethod) -> String {
        switch method {
        case .atm:
            return "ATM"
        case .momo:
            return "MoMo"
        case .transfer:
            return "Chuyển khoản"
        case .visa:
            return "Visa"
        case .zalo:
            return "ZaloPay"
        }
    }
}

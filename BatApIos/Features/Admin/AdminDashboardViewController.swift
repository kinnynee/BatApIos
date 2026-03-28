import UIKit

final class AdminDashboardViewController: StoryboardScreenViewController {
    @IBOutlet private weak var adminNameLabel: UILabel!
    @IBOutlet private weak var mainContentStack: UIStackView!
    @IBOutlet private weak var contentHeightConstraint: NSLayoutConstraint!

    private let store = AppMockStore.shared
    private let bookingsService = BackendBookingsService.shared
    private let authService = BackendAuthService.shared

    private let bookingCodeTextField = UITextField()
    private let resultTitleLabel = UILabel()
    private let resultDetailLabel = UILabel()
    private let resultBadgeLabel = UILabel()
    private let checkInButton = UIButton(type: .system)

    private var currentBooking: BackendBookingRecord?
    private var currentCustomerName: String?

    override var screenTitleText: String {
        "Admin Dashboard"
    }

    override var screenSubtitleText: String {
        "Màn hình tổng quan cho quản trị viên theo dõi vận hành hệ thống. Dữ liệu lấy từ store nội bộ của ứng dụng."
    }

    override var screenHighlights: [String] {
        [
            "Tổng doanh thu: \(currencyText(store.totalRevenue()))",
            "Số booking: \(store.bookingCount()) • Đã thanh toán: \(store.paidBookingCount())",
            "Số người dùng demo: \(store.userCount())"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminIdentity()
        configureAdminActions()
        configureBookingSearchCard()
    }

    private func configureAdminIdentity() {
        adminNameLabel?.text = store.currentUser?.username ?? "Admin"
    }

    private func currencyText(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0 đ"
    }

    private func configureAdminActions() {
        guard let mainContentStack else { return }

        let actionsTitle = UILabel()
        actionsTitle.font = .boldSystemFont(ofSize: 20)
        actionsTitle.text = "Điều hướng quản trị"

        let actionsStack = UIStackView()
        actionsStack.axis = .vertical
        actionsStack.spacing = 12

        actionsStack.addArrangedSubview(makeActionButton(title: "Báo cáo doanh thu", storyboardID: "RevenueReportVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Nhật ký hệ thống", storyboardID: "SystemLogsVC"))

        mainContentStack.addArrangedSubview(actionsTitle)
        mainContentStack.addArrangedSubview(actionsStack)
    }

    private func configureBookingSearchCard() {
        guard let mainContentStack else { return }

        let sectionTitle = UILabel()
        sectionTitle.font = .boldSystemFont(ofSize: 20)
        sectionTitle.text = "Check-in khách hàng"

        let descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Admin nhập mã booking để tìm booking đã tạo trên backend và check-in hộ khách ngay tại quầy."

        bookingCodeTextField.borderStyle = .none
        bookingCodeTextField.placeholder = "Nhập mã booking, ví dụ BK-172417..."
        bookingCodeTextField.font = .systemFont(ofSize: 15, weight: .medium)
        bookingCodeTextField.autocapitalizationType = .allCharacters
        bookingCodeTextField.returnKeyType = .search
        bookingCodeTextField.delegate = self

        let textContainer = UIView()
        textContainer.backgroundColor = .white
        textContainer.layer.cornerRadius = 16
        textContainer.layer.borderWidth = 1
        textContainer.layer.borderColor = UIColor.systemGray5.cgColor
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        bookingCodeTextField.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(bookingCodeTextField)

        let searchButton = UIButton(type: .system)
        searchButton.configuration = makeFilledButtonConfiguration(
            title: "Tìm",
            backgroundColor: UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1),
            foregroundColor: .white
        )
        searchButton.addTarget(self, action: #selector(searchBookingTapped), for: .touchUpInside)

        let searchRow = UIStackView(arrangedSubviews: [textContainer, searchButton])
        searchRow.axis = .horizontal
        searchRow.spacing = 12

        NSLayoutConstraint.activate([
            textContainer.heightAnchor.constraint(equalToConstant: 52),
            bookingCodeTextField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 16),
            bookingCodeTextField.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -16),
            bookingCodeTextField.topAnchor.constraint(equalTo: textContainer.topAnchor),
            bookingCodeTextField.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 90)
        ])

        let resultCard = UIStackView()
        resultCard.axis = .vertical
        resultCard.spacing = 12
        resultCard.backgroundColor = .white
        resultCard.isLayoutMarginsRelativeArrangement = true
        resultCard.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        resultCard.layer.cornerRadius = 18
        resultCard.layer.borderWidth = 1
        resultCard.layer.borderColor = UIColor.systemGray5.cgColor

        resultBadgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        resultBadgeLabel.textAlignment = .center
        resultBadgeLabel.layer.cornerRadius = 10
        resultBadgeLabel.clipsToBounds = true
        resultBadgeLabel.text = "CHƯA TÌM"
        resultBadgeLabel.textColor = .secondaryLabel
        resultBadgeLabel.backgroundColor = UIColor.systemGray6
        NSLayoutConstraint.activate([
            resultBadgeLabel.heightAnchor.constraint(equalToConstant: 28),
            resultBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 92)
        ])

        resultTitleLabel.font = .boldSystemFont(ofSize: 18)
        resultTitleLabel.numberOfLines = 2
        resultTitleLabel.text = "Chưa có booking nào được chọn"

        resultDetailLabel.font = .systemFont(ofSize: 14, weight: .medium)
        resultDetailLabel.textColor = .secondaryLabel
        resultDetailLabel.numberOfLines = 0
        resultDetailLabel.text = "Booking hợp lệ sẽ hiển thị mã, mã khách, sân và khung giờ để admin xác nhận check-in."

        checkInButton.configuration = makeFilledButtonConfiguration(
            title: "Check-in khách",
            backgroundColor: .systemMint,
            foregroundColor: .label
        )
        checkInButton.isEnabled = false
        checkInButton.addTarget(self, action: #selector(checkInTapped), for: .touchUpInside)

        resultCard.addArrangedSubview(resultBadgeLabel)
        resultCard.addArrangedSubview(resultTitleLabel)
        resultCard.addArrangedSubview(resultDetailLabel)
        resultCard.addArrangedSubview(checkInButton)

        let sectionStack = UIStackView(arrangedSubviews: [sectionTitle, descriptionLabel, searchRow, resultCard])
        sectionStack.axis = .vertical
        sectionStack.spacing = 14

        mainContentStack.addArrangedSubview(sectionStack)
        contentHeightConstraint?.constant = max(contentHeightConstraint?.constant ?? 800, 1080)
    }

    private func makeActionButton(title: String, storyboardID: String) -> UIButton {
        let button = UIButton(type: .system)
        button.configuration = makeFilledButtonConfiguration(
            title: title,
            backgroundColor: .systemBlue,
            foregroundColor: .white
        )
        button.addAction(UIAction { [weak self] _ in
            self?.openScreen(with: storyboardID)
        }, for: .touchUpInside)
        return button
    }

    private func makeFilledButtonConfiguration(
        title: String,
        backgroundColor: UIColor,
        foregroundColor: UIColor
    ) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = backgroundColor
        configuration.baseForegroundColor = foregroundColor
        return configuration
    }

    private func openScreen(with storyboardID: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID)
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }

    @objc private func searchBookingTapped() {
        let code = bookingCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !code.isEmpty else {
            showAlert(title: "Thiếu mã", message: "Vui lòng nhập mã booking để tìm.")
            return
        }

        checkInButton.isEnabled = false
        currentCustomerName = nil
        resultBadgeLabel.text = "ĐANG TÌM"
        resultBadgeLabel.textColor = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1)
        resultBadgeLabel.backgroundColor = UIColor.systemGray6
        resultTitleLabel.text = "Đang tìm booking..."
        resultDetailLabel.text = "Hệ thống đang truy vấn dữ liệu booking từ backend."

        Task { [weak self] in
            guard let self else { return }

            do {
                let booking = try await bookingsService.findBooking(by: code)
                let customerName = try await self.resolveCustomerName(for: booking)
                await MainActor.run {
                    if let booking {
                        self.currentBooking = booking
                        self.currentCustomerName = customerName
                        self.render(booking: booking)
                    } else {
                        self.currentBooking = nil
                        self.currentCustomerName = nil
                        self.renderMissingBooking(code: code)
                    }
                }
            } catch {
                await MainActor.run {
                    self.currentBooking = nil
                    self.currentCustomerName = nil
                    self.resultBadgeLabel.text = "LỖI"
                    self.resultBadgeLabel.textColor = .white
                    self.resultBadgeLabel.backgroundColor = .systemRed
                    self.resultTitleLabel.text = "Không tải được booking"
                    self.resultDetailLabel.text = error.localizedDescription
                    self.checkInButton.isEnabled = false
                }
            }
        }
    }

    @objc private func checkInTapped() {
        guard let booking = currentBooking else { return }

        checkInButton.isEnabled = false
        checkInButton.configuration?.showsActivityIndicator = true

        Task { [weak self] in
            guard let self else { return }

            do {
                let updatedBooking = try await bookingsService.updateBookingStatus(
                    bookingId: booking.id,
                    bookingStatus: "Active",
                    paymentStatus: booking.paymentStatus
                )
                await MainActor.run {
                    self.checkInButton.configuration?.showsActivityIndicator = false
                    self.currentBooking = updatedBooking
                    self.renderCheckedInBooking(updatedBooking)
                    self.showAlert(title: "Check-in thành công", message: "Khách đã được admin check-in vào sân.")
                }
            } catch {
                await MainActor.run {
                    self.checkInButton.isEnabled = true
                    self.checkInButton.configuration?.showsActivityIndicator = false
                    self.showAlert(title: "Không thể check-in", message: error.localizedDescription)
                }
            }
        }
    }

    private func render(booking: BackendBookingRecord) {
        let status = bookingsService.orderStatus(for: booking)
        let customerDisplayName = displayName(for: booking)
        resultBadgeLabel.text = status.title.uppercased()
        resultBadgeLabel.textColor = status == .success ? UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1) : .white
        resultBadgeLabel.backgroundColor = status == .success ? UIColor.systemMint.withAlphaComponent(0.28) : status.tintColor
        resultTitleLabel.text = booking.courtName
        resultDetailLabel.text = """
        Mã booking: \(booking.bookingCode)
        Khách: \(customerDisplayName)
        Khung giờ: \(booking.bookingDate) • \(booking.startTime)-\(booking.endTime)
        Trạng thái: \(booking.bookingStatus) • Thanh toán: \(booking.paymentStatus)
        """
        checkInButton.isEnabled = booking.bookingStatus.lowercased() != "active"
    }

    private func renderCheckedInBooking(_ booking: BackendBookingRecord) {
        let customerDisplayName = displayName(for: booking)
        resultBadgeLabel.text = "ĐÃ CHECK-IN"
        resultBadgeLabel.textColor = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1)
        resultBadgeLabel.backgroundColor = UIColor.systemMint.withAlphaComponent(0.28)
        resultTitleLabel.text = booking.courtName
        resultDetailLabel.text = """
        Mã booking: \(booking.bookingCode)
        Khách: \(customerDisplayName)
        Khung giờ: \(booking.bookingDate) • \(booking.startTime)-\(booking.endTime)
        Trạng thái hiện tại: \(booking.bookingStatus)
        """
        checkInButton.isEnabled = false
    }

    private func renderMissingBooking(code: String) {
        resultBadgeLabel.text = "KHÔNG THẤY"
        resultBadgeLabel.textColor = .white
        resultBadgeLabel.backgroundColor = .systemOrange
        resultTitleLabel.text = "Không có booking hợp lệ"
        resultDetailLabel.text = "Không tìm thấy booking \(code.uppercased()) trong nhóm booking `Fully Paid` hoặc `Pending`."
        checkInButton.isEnabled = false
    }

    private func resolveCustomerName(for booking: BackendBookingRecord?) async throws -> String? {
        guard let booking else { return nil }

        let profile = try await authService.getProfile(uid: booking.userId)
        let trimmedName = profile.fullName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedName, !trimmedName.isEmpty {
            return trimmedName
        }

        let trimmedEmail = profile.email?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmedEmail, !trimmedEmail.isEmpty {
            return trimmedEmail
        }

        return nil
    }

    private func displayName(for booking: BackendBookingRecord) -> String {
        if let currentCustomerName, !currentCustomerName.isEmpty {
            return currentCustomerName
        }

        return booking.userId
    }
}

extension AdminDashboardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBookingTapped()
        textField.resignFirstResponder()
        return true
    }
}

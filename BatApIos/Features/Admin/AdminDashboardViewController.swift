import UIKit

final class AdminDashboardViewController: StoryboardScreenViewController {
    @IBOutlet private weak var adminNameLabel: UILabel!
    @IBOutlet private weak var mainContentStack: UIStackView!
    @IBOutlet private weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var quickActionPrimaryButton: UIButton!
    @IBOutlet private weak var quickActionSecondaryButton: UIButton!
    @IBOutlet private weak var quickActionsSectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var courtStatusStackView: UIStackView!
    @IBOutlet private weak var courtStatusSectionHeightConstraint: NSLayoutConstraint!

    private let store = AppMockStore.shared
    private let adminService = BackendAdminService.shared
    private let bookingsService = BackendBookingsService.shared
    private let courtsService = BackendCourtsService.shared
    private let authService = BackendAuthService.shared
    private let systemLogStore = SystemLogStore.shared
    private var overview: BackendAdminOverview?
    private let adminDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

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
        "Màn hình tổng quan cho quản trị viên theo dõi vận hành hệ thống. Dữ liệu ưu tiên lấy từ backend admin."
    }

    override var screenHighlights: [String] {
        if let overview {
            return [
                "Tổng doanh thu: \(currencyText(overview.totalRevenue))",
                "Số booking: \(overview.totalBookings) • Thanh toán: \(overview.totalPayments)",
                "Số người dùng: \(overview.totalUsers) • Sân: \(overview.totalCourts)"
            ]
        }

        return [
            "Tổng doanh thu: \(currencyText(store.totalRevenue()))",
            "Số booking: \(store.bookingCount()) • Đã thanh toán: \(store.paidBookingCount())",
            "Số người dùng demo: \(store.userCount())"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminIdentity()
        configureQuickActionSizing()
        configureAdminActions()
        configureBookingSearchCard()
        loadOverview()
        loadCourtStatuses()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentHeightIfNeeded()
    }

    private func configureAdminIdentity() {
        adminNameLabel?.text = authService.restorePersistedUser()?.username ?? store.currentUser?.username ?? "Admin"
    }

    private func configureQuickActionSizing() {
        quickActionsSectionHeightConstraint?.constant = 212
        [quickActionPrimaryButton, quickActionSecondaryButton].forEach { button in
            button?.heightAnchor.constraint(equalToConstant: 56).isActive = true
        }
        view.layoutIfNeeded()
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

        actionsStack.addArrangedSubview(makeActionButton(title: "Quản lý người dùng") { [weak self] in
            self?.pushManagementController(StaffManagementViewController())
        })
        actionsStack.addArrangedSubview(makeActionButton(title: "Quản lý sân") { [weak self] in
            self?.pushManagementController(CourtManagementViewController())
        })
        actionsStack.addArrangedSubview(makeActionButton(title: "Quản lý booking") { [weak self] in
            self?.pushManagementController(BookingManagementViewController())
        })
        actionsStack.addArrangedSubview(makeActionButton(title: "Quản lý thanh toán") { [weak self] in
            self?.pushManagementController(PaymentManagementViewController())
        })
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
        updateContentHeightIfNeeded()
    }

    private func makeActionButton(title: String, storyboardID: String) -> UIButton {
        let button = UIButton(type: .system)
        button.configuration = makeFilledButtonConfiguration(
            title: title,
            backgroundColor: UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1),
            foregroundColor: .white
        )
        button.addAction(UIAction { [weak self] _ in
            self?.openScreen(with: storyboardID)
        }, for: .touchUpInside)
        return button
    }

    private func makeActionButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.configuration = makeFilledButtonConfiguration(
            title: title,
            backgroundColor: .systemMint,
            foregroundColor: .label
        )
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
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

    private func pushManagementController(_ viewController: UIViewController) {
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
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
                let adminId = self.authService.restorePersistedUser()?.id ?? "admin"
                let preparedBooking = try await self.prepareBookingForCheckIn(booking)
                let updatedBooking = try await self.adminService.checkInBooking(
                    bookingId: preparedBooking.id,
                    checkedInBy: adminId
                )
                await MainActor.run {
                    self.systemLogStore.append(
                        title: "Admin check-in",
                        message: "Admin \(adminId) đã check-in booking \(updatedBooking.bookingCode) từ dashboard.",
                        source: "admin"
                    )
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

    private func prepareBookingForCheckIn(_ booking: BackendBookingRecord) async throws -> BackendBookingRecord {
        let courts = try await courtsService.fetchCourtOptions()
        if courts.contains(where: { $0.id.caseInsensitiveCompare(booking.courtId) == .orderedSame }) {
            return booking
        }

        guard let resolvedCourt = resolveCourt(for: booking, from: courts) else {
            throw NSError(
                domain: "AdminDashboard",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Booking này đang trỏ tới sân không tồn tại trên backend. Hãy cập nhật lại courtId trước khi check-in."]
            )
        }

        return try await bookingsService.updateBooking(
            bookingId: booking.id,
            payload: [
                "courtId": resolvedCourt.id,
                "courtName": resolvedCourt.name
            ]
        )
    }

    private func resolveCourt(for booking: BackendBookingRecord, from courts: [BackendCourtOption]) -> BackendCourtOption? {
        let candidates = [booking.courtId, booking.courtName]
            .map(normalizedCourtToken(_:))
            .filter { !$0.isEmpty }

        if let directMatch = courts.first(where: { court in
            let courtTokens = [court.id, court.name, court.type].map(normalizedCourtToken(_:))
            return candidates.contains(where: { courtTokens.contains($0) })
        }) {
            return directMatch
        }

        if candidates.contains(where: { $0.contains("vip") }) {
            return courts.first(where: { normalizedCourtToken($0.id).contains("vip") || normalizedCourtToken($0.name).contains("vip") || normalizedCourtToken($0.type).contains("vip") })
        }

        if candidates.contains(where: { $0.contains("standard") || $0.contains("thuong") || $0.contains("bth") }) {
            return courts.first(where: {
                let id = normalizedCourtToken($0.id)
                let name = normalizedCourtToken($0.name)
                let type = normalizedCourtToken($0.type)
                return id.contains("thuong") || id.contains("bth") || name.contains("thuong") || type.contains("standard") || type.contains("single")
            })
        }

        return nil
    }

    private func normalizedCourtToken(_ raw: String) -> String {
        raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "vi_VN"))
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
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

    private func loadOverview() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let overview = try await adminService.fetchOverview()
                await MainActor.run {
                    self.overview = overview
                }
            } catch {
                // Keep local fallback.
            }
        }
    }

    private func loadCourtStatuses() {
        renderLoadingCourtStatuses()

        Task { [weak self] in
            guard let self else { return }

            do {
                async let courtsTask = adminService.fetchCourts()
                async let todayBookingsTask = adminService.fetchBookings(bookingDate: adminDateFormatter.string(from: Date()))
                let (courts, bookings) = try await (courtsTask, todayBookingsTask)
                let rows = self.makeCourtStatusRows(courts: courts, bookings: bookings)

                await MainActor.run {
                    self.renderCourtStatusRows(rows)
                }
            } catch {
                await MainActor.run {
                    self.renderCourtStatusRows([
                        CourtStatusRow(
                            title: "Không tải được sân đấu",
                            subtitle: "Kiểm tra lại dữ liệu sân hoặc kết nối backend.",
                            trailingText: "Lỗi",
                            tintColor: .systemRed,
                            showsDivider: false
                        )
                    ])
                }
            }
        }
    }

    private func renderLoadingCourtStatuses() {
        renderCourtStatusRows([
            CourtStatusRow(
                title: "Đang tải sân đấu",
                subtitle: "Đồng bộ danh sách sân và lịch đặt hôm nay từ backend.",
                trailingText: "--",
                tintColor: .systemGray,
                showsDivider: false
            )
        ])
    }

    private func makeCourtStatusRows(courts: [BackendAdminCourt], bookings: [BackendBookingRecord]) -> [CourtStatusRow] {
        let sortedCourts = courts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        guard sortedCourts.isEmpty == false else {
            return [
                CourtStatusRow(
                    title: "Chưa có sân đấu",
                    subtitle: "Backend chưa trả về sân nào để hiển thị trong dashboard.",
                    trailingText: "--",
                    tintColor: .systemGray,
                    showsDivider: false
                )
            ]
        }

        return sortedCourts.enumerated().map { index, court in
            let matchingBookings = bookings.filter { booking in
                booking.courtId.caseInsensitiveCompare(court.id) == .orderedSame ||
                booking.courtName.caseInsensitiveCompare(court.name) == .orderedSame
            }

            let liveBooking = matchingBookings.first(where: isBookingLiveNow(_:))
            let nextBooking = matchingBookings
                .filter { isBookingUpcomingToday($0) }
                .sorted { $0.startTime < $1.startTime }
                .first

            let row: CourtStatusRow
            if court.status.lowercased() == "maintenance" {
                row = CourtStatusRow(
                    title: court.name,
                    subtitle: "Bảo trì",
                    trailingText: "Tạm dừng",
                    tintColor: .systemOrange,
                    showsDivider: index < sortedCourts.count - 1
                )
            } else if let liveBooking {
                row = CourtStatusRow(
                    title: court.name,
                    subtitle: "Đang sử dụng • kết thúc \(liveBooking.endTime)",
                    trailingText: liveBooking.endTime,
                    tintColor: .systemRed,
                    showsDivider: index < sortedCourts.count - 1
                )
            } else if let nextBooking {
                row = CourtStatusRow(
                    title: court.name,
                    subtitle: "Trống • lượt kế tiếp \(nextBooking.startTime)",
                    trailingText: nextBooking.startTime,
                    tintColor: .systemMint,
                    showsDivider: index < sortedCourts.count - 1
                )
            } else {
                row = CourtStatusRow(
                    title: court.name,
                    subtitle: "Trống",
                    trailingText: "--",
                    tintColor: .systemMint,
                    showsDivider: index < sortedCourts.count - 1
                )
            }

            return row
        }
    }

    private func isBookingLiveNow(_ booking: BackendBookingRecord) -> Bool {
        let normalizedStatus = booking.bookingStatus.lowercased()
        let allowedStatuses = ["active", "checked_in", "checked in", "confirmed", "fully paid"]
        guard allowedStatuses.contains(normalizedStatus) else {
            return false
        }

        guard
            let startDate = resolvedDate(for: booking.bookingDate, time: booking.startTime),
            let endDate = resolvedDate(for: booking.bookingDate, time: booking.endTime)
        else {
            return false
        }

        let now = Date()
        return startDate <= now && now <= endDate
    }

    private func isBookingUpcomingToday(_ booking: BackendBookingRecord) -> Bool {
        guard let startDate = resolvedDate(for: booking.bookingDate, time: booking.startTime) else {
            return false
        }

        let normalizedStatus = booking.bookingStatus.lowercased()
        if ["cancelled", "completed"].contains(normalizedStatus) {
            return false
        }

        return startDate > Date()
    }

    private func resolvedDate(for bookingDate: String, time: String) -> Date? {
        let trimmedDate = bookingDate.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTime = time.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidateFormats = [
            "yyyy-MM-dd HH:mm",
            "yyyy-M-d HH:mm",
            "dd/MM/yyyy HH:mm",
            "d/M/yyyy HH:mm"
        ]

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.calendar = Calendar(identifier: .gregorian)

        for format in candidateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: "\(trimmedDate) \(trimmedTime)") {
                return date
            }
        }

        return nil
    }

    private func renderCourtStatusRows(_ rows: [CourtStatusRow]) {
        guard let courtStatusStackView else { return }

        courtStatusStackView.arrangedSubviews.forEach { view in
            courtStatusStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        rows.forEach { row in
            courtStatusStackView.addArrangedSubview(makeCourtStatusRowView(row))
        }

        courtStatusSectionHeightConstraint?.constant = CGFloat(24 + max(rows.count, 1) * 56)
        view.layoutIfNeeded()
        updateContentHeightIfNeeded()
    }

    private func makeCourtStatusRowView(_ row: CourtStatusRow) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = row.tintColor
        dotView.layer.cornerRadius = 4

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 10)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = row.title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .label
        subtitleLabel.text = row.subtitle
        subtitleLabel.numberOfLines = 1

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2

        let trailingLabel = UILabel()
        trailingLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        trailingLabel.textColor = .secondaryLabel
        trailingLabel.textAlignment = .right
        trailingLabel.text = row.trailingText
        trailingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        container.addSubview(dotView)
        container.addSubview(textStack)
        container.addSubview(trailingLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 56),
            dotView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            dotView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            textStack.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            trailingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 12),
            trailingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            trailingLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        if row.showsDivider {
            let divider = UIView()
            divider.translatesAutoresizingMaskIntoConstraints = false
            divider.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.968, alpha: 1)
            container.addSubview(divider)
            NSLayoutConstraint.activate([
                divider.heightAnchor.constraint(equalToConstant: 1),
                divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                divider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                divider.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }

        return container
    }

    private func updateContentHeightIfNeeded() {
        guard
            let mainContentStack,
            let contentHeightConstraint
        else { return }

        let targetSize = CGSize(width: mainContentStack.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let stackHeight = mainContentStack.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let requiredHeight = max(800, stackHeight + 32)
        if abs(contentHeightConstraint.constant - requiredHeight) > 1 {
            contentHeightConstraint.constant = requiredHeight
        }
    }
}

private struct CourtStatusRow {
    let title: String
    let subtitle: String
    let trailingText: String
    let tintColor: UIColor
    let showsDivider: Bool
}

extension AdminDashboardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBookingTapped()
        textField.resignFirstResponder()
        return true
    }
}

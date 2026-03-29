import UIKit

final class CourtsViewController: StoryboardScreenViewController {
    @IBOutlet private weak var cardsStackView: UIStackView!
    @IBOutlet private weak var cardsContentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var allFilterButton: UIButton!
    @IBOutlet private weak var availableFilterButton: UIButton!
    @IBOutlet private weak var occupiedFilterButton: UIButton!
    @IBOutlet private weak var maintenanceFilterButton: UIButton!

    private let courtsService = BackendCourtsService.shared
    private let bookingsService = BackendBookingsService.shared
    private let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private var courtRows: [CourtRow] = []
    private var selectedFilter: CourtFilter = .all

    override var screenTitleText: String {
        "Danh sách sân"
    }

    override var screenSubtitleText: String {
        "Màn hình dùng để xem danh sách sân đấu theo trạng thái thực tế từ backend."
    }

    override var screenHighlights: [String] {
        [
            "Hiển thị sân trống, đang dùng hoặc bảo trì",
            "Bám dữ liệu từ /api/courts và booking hôm nay",
            "Lọc nhanh để chọn sân phù hợp"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureFilters()
        renderLoadingState()
        loadCourts()
    }

    private func configureFilters() {
        updateFilterButtonStyles()
    }

    private func loadCourts() {
        Task { [weak self] in
            guard let self else { return }

            do {
                async let courtsTask = courtsService.fetchCourts()
                async let bookingsTask = bookingsService.fetchBookings(
                    bookingDate: apiDateFormatter.string(from: Date())
                )
                let (courts, bookings) = try await (courtsTask, bookingsTask)
                let rows = buildCourtRows(courts: courts, bookings: bookings)

                await MainActor.run {
                    self.courtRows = rows
                    self.renderFilteredRows()
                }
            } catch {
                await MainActor.run {
                    self.renderRows([
                        CourtRow(
                            id: "",
                            name: "Không tải được sân đấu",
                            subtitle: error.localizedDescription,
                            badgeText: "LỖI",
                            badgeBackgroundColor: .systemRed.withAlphaComponent(0.16),
                            badgeTextColor: .systemRed,
                            trailingTitle: "Backend",
                            trailingSubtitle: "Kiểm tra API",
                            iconTintColor: .systemRed,
                            isBookable: false
                        )
                    ])
                }
            }
        }
    }

    private func buildCourtRows(courts: [BackendCourtCard], bookings: [BackendBookingRecord]) -> [CourtRow] {
        let sortedCourts = courts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return sortedCourts.map { court in
            let matchingBookings = bookings.filter {
                $0.courtId.caseInsensitiveCompare(court.id) == .orderedSame ||
                $0.courtName.caseInsensitiveCompare(court.name) == .orderedSame
            }

            if court.status.lowercased() == "maintenance" {
                return CourtRow(
                    id: court.id,
                    name: court.name,
                    subtitle: "\(normalizedType(court.type)) • Tạm ngừng khai thác",
                    badgeText: "BẢO TRÌ",
                    badgeBackgroundColor: .systemOrange.withAlphaComponent(0.16),
                    badgeTextColor: .systemOrange,
                    trailingTitle: court.priceText,
                    trailingSubtitle: "Chưa mở lại",
                    iconTintColor: .systemOrange,
                    isBookable: false
                )
            }

            if let liveBooking = matchingBookings.first(where: isBookingLiveNow(_:)) {
                return CourtRow(
                    id: court.id,
                    name: court.name,
                    subtitle: "\(normalizedType(court.type)) • Có lịch đang diễn ra",
                    badgeText: "ĐANG DÙNG",
                    badgeBackgroundColor: .systemRed.withAlphaComponent(0.14),
                    badgeTextColor: .systemRed,
                    trailingTitle: "Đến \(liveBooking.endTime)",
                    trailingSubtitle: court.priceText,
                    iconTintColor: .systemRed,
                    isBookable: false
                )
            }

            if let nextBooking = matchingBookings
                .filter({ isBookingUpcomingToday($0) })
                .sorted(by: { $0.startTime < $1.startTime })
                .first
            {
                return CourtRow(
                    id: court.id,
                    name: court.name,
                    subtitle: "\(normalizedType(court.type)) • Sẵn sàng nhận lịch mới",
                    badgeText: "TRỐNG",
                    badgeBackgroundColor: UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 0.16),
                    badgeTextColor: UIColor(red: 0.0, green: 0.70, blue: 0.36, alpha: 1),
                    trailingTitle: "Lượt kế \(nextBooking.startTime)",
                    trailingSubtitle: court.priceText,
                    iconTintColor: UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 1),
                    isBookable: true
                )
            }

            return CourtRow(
                id: court.id,
                name: court.name,
                subtitle: "\(normalizedType(court.type)) • Sẵn sàng",
                badgeText: "TRỐNG",
                badgeBackgroundColor: UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 0.16),
                badgeTextColor: UIColor(red: 0.0, green: 0.70, blue: 0.36, alpha: 1),
                trailingTitle: court.priceText,
                trailingSubtitle: "Có thể đặt ngay",
                iconTintColor: UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 1),
                isBookable: true
            )
        }
    }

    private func renderLoadingState() {
        renderRows([
            CourtRow(
                id: "",
                name: "Đang tải sân đấu",
                subtitle: "Ứng dụng đang đồng bộ danh sách sân từ backend.",
                badgeText: "ĐANG TẢI",
                badgeBackgroundColor: .systemGray5,
                badgeTextColor: .secondaryLabel,
                trailingTitle: "--",
                trailingSubtitle: "Vui lòng chờ",
                iconTintColor: .systemGray,
                isBookable: false
            )
        ])
    }

    private func renderFilteredRows() {
        let rows = filteredRows()

        if rows.isEmpty {
            renderRows([
                CourtRow(
                    id: "",
                    name: "Không có sân phù hợp",
                    subtitle: "Bộ lọc hiện tại chưa có sân nào khớp.",
                    badgeText: "RỖNG",
                    badgeBackgroundColor: .systemGray5,
                    badgeTextColor: .secondaryLabel,
                    trailingTitle: "--",
                    trailingSubtitle: "Đổi bộ lọc",
                    iconTintColor: .systemGray,
                    isBookable: false
                )
            ])
            return
        }

        renderRows(rows)
    }

    private func filteredRows() -> [CourtRow] {
        courtRows.filter { row in
            switch selectedFilter {
            case .all:
                return true
            case .available:
                return row.badgeText == "TRỐNG"
            case .occupied:
                return row.badgeText == "ĐANG DÙNG"
            case .maintenance:
                return row.badgeText == "BẢO TRÌ"
            }
        }
    }

    private func renderRows(_ rows: [CourtRow]) {
        cardsStackView.arrangedSubviews.forEach { view in
            cardsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        rows.enumerated().forEach { index, row in
            cardsStackView.addArrangedSubview(makeCardView(for: row, index: index))
        }

        cardsContentHeightConstraint.constant = CGFloat(max(rows.count, 1)) * 108 + CGFloat(max(rows.count - 1, 0) * 16) + 32
        view.layoutIfNeeded()
    }

    private func makeCardView(for row: CourtRow, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(red: 0.949, green: 0.949, blue: 0.968, alpha: 1).cgColor
        container.tag = index

        let iconBackgroundView = UIView()
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = row.iconTintColor.withAlphaComponent(0.12)
        iconBackgroundView.layer.cornerRadius = 26

        let iconView = UIImageView(image: UIImage(systemName: "figure.badminton"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = row.iconTintColor
        iconView.contentMode = .scaleAspectFit

        iconBackgroundView.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.text = row.name

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = row.subtitle

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4

        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = .boldSystemFont(ofSize: 10)
        badgeLabel.textAlignment = .center
        badgeLabel.text = row.badgeText
        badgeLabel.textColor = row.badgeTextColor
        badgeLabel.backgroundColor = row.badgeBackgroundColor
        badgeLabel.layer.cornerRadius = 11
        badgeLabel.clipsToBounds = true

        let trailingTitleLabel = UILabel()
        trailingTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingTitleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        trailingTitleLabel.textColor = .label
        trailingTitleLabel.textAlignment = .right
        trailingTitleLabel.text = row.trailingTitle

        let trailingSubtitleLabel = UILabel()
        trailingSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        trailingSubtitleLabel.font = .systemFont(ofSize: 12)
        trailingSubtitleLabel.textColor = row.isBookable ? row.iconTintColor : .secondaryLabel
        trailingSubtitleLabel.textAlignment = .right
        trailingSubtitleLabel.text = row.isBookable ? "Chạm để đặt sân" : unavailableHint(for: row)

        let trailingStack = UIStackView(arrangedSubviews: [badgeLabel, trailingTitleLabel, trailingSubtitleLabel])
        trailingStack.translatesAutoresizingMaskIntoConstraints = false
        trailingStack.axis = .vertical
        trailingStack.alignment = .trailing
        trailingStack.spacing = 6

        container.addSubview(iconBackgroundView)
        container.addSubview(textStack)
        container.addSubview(trailingStack)

        let actionButton = UIButton(type: .custom)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = .clear
        actionButton.tag = index
        actionButton.addTarget(self, action: #selector(courtCardButtonTapped(_:)), for: .touchUpInside)
        container.addSubview(actionButton)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 92),

            iconBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 52),

            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            textStack.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingStack.leadingAnchor, constant: -12),

            trailingStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            trailingStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            badgeLabel.heightAnchor.constraint(equalToConstant: 22),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 76),

            actionButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            actionButton.topAnchor.constraint(equalTo: container.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    @objc private func courtCardButtonTapped(_ sender: UIButton) {
        let rows = filteredRows()
        guard rows.indices.contains(sender.tag) else { return }
        handleSelection(for: rows[sender.tag])
    }

    private func handleSelection(for row: CourtRow) {
        guard row.id.isEmpty == false else { return }

        guard row.isBookable else {
            showAlert(
                title: "Không thể đặt sân",
                message: unavailableMessage(for: row)
            )
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let bookingViewController = storyboard.instantiateViewController(withIdentifier: "NewCourtBookingVC") as? NewCourtBookingViewController else {
            return
        }

        bookingViewController.preselectedCourtID = row.id
        bookingViewController.preselectedCourtName = row.name
        if let navigationController {
            navigationController.pushViewController(bookingViewController, animated: true)
            return
        }

        let navigationController = UINavigationController(rootViewController: bookingViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func unavailableHint(for row: CourtRow) -> String {
        switch row.badgeText {
        case "ĐANG DÙNG":
            return "Sân đang có người sử dụng"
        case "BẢO TRÌ":
            return "Sân đang bảo trì"
        default:
            return row.trailingSubtitle
        }
    }

    private func unavailableMessage(for row: CourtRow) -> String {
        switch row.badgeText {
        case "ĐANG DÙNG":
            return "\(row.name) hiện đang được sử dụng. Vui lòng chọn sân trống khác."
        case "BẢO TRÌ":
            return "\(row.name) đang trong trạng thái bảo trì nên chưa thể đặt."
        default:
            return "Sân này hiện chưa thể đặt. Vui lòng thử lại sau."
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
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.calendar = Calendar(identifier: .gregorian)

        for format in ["yyyy-MM-dd HH:mm", "dd/MM/yyyy HH:mm", "d/M/yyyy HH:mm"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: "\(bookingDate) \(time)") {
                return date
            }
        }

        return nil
    }

    private func normalizedType(_ value: String) -> String {
        switch value.lowercased() {
        case "vip":
            return "Sân VIP"
        case "single":
            return "Sân đơn"
        case "double":
            return "Sân đôi"
        default:
            return value.capitalized
        }
    }

    private func updateFilterButtonStyles() {
        let configs: [(UIButton?, CourtFilter)] = [
            (allFilterButton, .all),
            (availableFilterButton, .available),
            (occupiedFilterButton, .occupied),
            (maintenanceFilterButton, .maintenance)
        ]

        for (button, filter) in configs {
            let isSelected = selectedFilter == filter
            button?.backgroundColor = isSelected
                ? UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 1)
                : UIColor(red: 0.9215, green: 0.9215, blue: 0.9411, alpha: 1)
            button?.tintColor = isSelected ? .black : .darkGray
        }
    }

    @IBAction private func allFilterTapped(_ sender: UIButton) {
        selectedFilter = .all
        updateFilterButtonStyles()
        renderFilteredRows()
    }

    @IBAction private func availableFilterTapped(_ sender: UIButton) {
        selectedFilter = .available
        updateFilterButtonStyles()
        renderFilteredRows()
    }

    @IBAction private func occupiedFilterTapped(_ sender: UIButton) {
        selectedFilter = .occupied
        updateFilterButtonStyles()
        renderFilteredRows()
    }

    @IBAction private func maintenanceFilterTapped(_ sender: UIButton) {
        selectedFilter = .maintenance
        updateFilterButtonStyles()
        renderFilteredRows()
    }
}

private extension CourtsViewController {
    enum CourtFilter {
        case all
        case available
        case occupied
        case maintenance
    }

    struct CourtRow {
        let id: String
        let name: String
        let subtitle: String
        let badgeText: String
        let badgeBackgroundColor: UIColor
        let badgeTextColor: UIColor
        let trailingTitle: String
        let trailingSubtitle: String
        let iconTintColor: UIColor
        let isBookable: Bool
    }
}

import UIKit

final class DiscoverViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared
    private let courtsService = BackendCourtsService.shared

    @IBOutlet private weak var greetingLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var firstCourtCardView: UIView!
    @IBOutlet private weak var secondCourtCardView: UIView!

    override var screenTitleText: String {
        "Khám phá"
    }

    override var screenSubtitleText: String {
        "Màn hình gợi ý sân nổi bật, khuyến mãi và các gói dịch vụ. Dữ liệu gợi ý đang bám theo booking hiện có của người dùng."
    }

    override var screenHighlights: [String] {
        [
            "Gợi ý đặt lại: \(store.latestBooking()?.courtName ?? "Sân VIP 02")",
            "Ưu đãi ví thành viên: \(store.membershipSummary())",
            "Số thông báo chưa đọc theo session demo: \(store.notificationsForCurrentUser().count)"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStaticUI()
        refreshWelcomeMessage()
        renderLoadingState()
        loadCourts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshWelcomeMessage()
    }

    private func configureStaticUI() {
        [firstCourtCardView, secondCourtCardView].forEach { cardView in
            cardView?.layer.cornerRadius = 12
            cardView?.backgroundColor = .white
            cardView?.clipsToBounds = true
        }
    }

    private func refreshWelcomeMessage() {
        let username = store.currentUser?.username.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = (username?.isEmpty == false ? username : nil) ?? "User"

        greetingLabel.text = "Chào mừng trở lại"
        nameLabel.text = "Chào buổi sáng, \(displayName)"
    }

    private func loadCourts() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let courts = try await courtsService.fetchCourts()
                await MainActor.run {
                    self.renderCourts(courts)
                }
            } catch {
                await MainActor.run {
                    self.renderCourtsError(error.localizedDescription)
                }
            }
        }
    }

    private func renderLoadingState() {
        renderCard(
            in: firstCourtCardView,
            title: "Đang tải sân...",
            subtitle: "Ứng dụng đang lấy dữ liệu từ backend."
        )
        renderCard(
            in: secondCourtCardView,
            title: "Đang tải sân...",
            subtitle: "Vui lòng chờ trong giây lát."
        )
    }

    private func renderCourts(_ courts: [BackendCourtCard]) {
        if let firstCourt = courts.first {
            renderCard(
                in: firstCourtCardView,
                title: firstCourt.name,
                subtitle: "\(firstCourt.type) • \(normalizedStatus(firstCourt.status))\n\(firstCourt.priceText)/giờ"
            )
        } else {
            renderEmptyCard(in: firstCourtCardView)
        }

        if courts.count > 1 {
            let secondCourt = courts[1]
            renderCard(
                in: secondCourtCardView,
                title: secondCourt.name,
                subtitle: "\(secondCourt.type) • \(normalizedStatus(secondCourt.status))\n\(secondCourt.priceText)/giờ"
            )
        } else {
            renderCard(
                in: secondCourtCardView,
                title: "Xem thêm sân",
                subtitle: "Hiện backend chỉ trả về một sân khả dụng."
            )
        }
    }

    private func renderCourtsError(_ message: String) {
        renderCard(
            in: firstCourtCardView,
            title: "Không tải được sân",
            subtitle: message
        )
        renderCard(
            in: secondCourtCardView,
            title: "Kiểm tra API /api/courts",
            subtitle: "Đảm bảo backend đang chạy và có dữ liệu sân."
        )
    }

    private func renderEmptyCard(in cardView: UIView?) {
        renderCard(
            in: cardView,
            title: "Chưa có sân",
            subtitle: "Backend chưa trả về sân nào để hiển thị."
        )
    }

    private func renderCard(in cardView: UIView?, title: String, subtitle: String) {
        guard let cardView else { return }

        cardView.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.text = title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = subtitle

        let statusPill = UILabel()
        statusPill.translatesAutoresizingMaskIntoConstraints = false
        statusPill.font = .systemFont(ofSize: 12, weight: .semibold)
        statusPill.textColor = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1)
        statusPill.backgroundColor = UIColor(red: 0.78, green: 0.98, blue: 0.89, alpha: 1)
        statusPill.layer.cornerRadius = 10
        statusPill.clipsToBounds = true
        statusPill.textAlignment = .center
        statusPill.text = "SÂN"

        let stackView = UIStackView(arrangedSubviews: [statusPill, titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

        cardView.addSubview(stackView)

        NSLayoutConstraint.activate([
            statusPill.heightAnchor.constraint(equalToConstant: 28),
            statusPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),

            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -18)
        ])
    }

    private func normalizedStatus(_ value: String) -> String {
        switch value.lowercased() {
        case "active", "available":
            return "Sẵn sàng"
        case "inactive":
            return "Tạm dừng"
        case "maintenance":
            return "Bảo trì"
        default:
            return value
        }
    }

    @IBAction private func notificationButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showNotifications", sender: sender)
    }
}

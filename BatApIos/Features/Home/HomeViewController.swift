import UIKit

final class HomeViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared
    private let courtsService = BackendCourtsService.shared
    private let welcomeLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statsCard = UIStackView()
    private let courtsStack = UIStackView()

    override var screenTitleText: String {
        "Chào mừng trở lại, \(store.currentUser?.username ?? "người chơi")"
    }

    override var screenSubtitleText: String {
        "Điểm vào chính cho người dùng với các lối tắt đặt sân, xem lịch và thông báo. Booking gần nhất: \(store.latestBookingSummary())"
    }

    override var screenHighlights: [String] {
        [
            "Số booking hiện có: \(store.bookingCount())",
            "Đã thanh toán: \(store.paidBookingCount())",
            "Hạng thành viên: \(store.membershipSummary())"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDashboardUI()
        configureQuickActions()
        loadCourts()
    }

    private func configureDashboardUI() {
        view.subviews.forEach { $0.removeFromSuperview() }

        welcomeLabel.font = .boldSystemFont(ofSize: 30)
        welcomeLabel.numberOfLines = 0
        welcomeLabel.text = screenTitleText

        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Danh sách sân sẽ được tải từ backend và hiển thị ngay tại dashboard."

        statsCard.axis = .vertical
        statsCard.spacing = 10
        statsCard.backgroundColor = .secondarySystemBackground
        statsCard.layer.cornerRadius = 18
        statsCard.isLayoutMarginsRelativeArrangement = true
        statsCard.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)

        let stats = [
            "Số booking hiện có: \(store.bookingCount())",
            "Đã thanh toán: \(store.paidBookingCount())",
            "Hạng thành viên: \(store.membershipSummary())"
        ]

        for item in stats {
            let label = UILabel()
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.numberOfLines = 0
            label.text = "• \(item)"
            statsCard.addArrangedSubview(label)
        }

        let courtsTitle = UILabel()
        courtsTitle.font = .boldSystemFont(ofSize: 20)
        courtsTitle.text = "Sân hiện có"

        courtsStack.axis = .vertical
        courtsStack.spacing = 12
        courtsStack.addArrangedSubview(makeStateLabel(text: "Đang tải danh sách sân..."))

        let contentStack = UIStackView(arrangedSubviews: [
            welcomeLabel,
            subtitleLabel,
            statsCard,
            courtsTitle,
            courtsStack
        ])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func configureQuickActions() {
        let actionsTitle = UILabel()
        actionsTitle.font = .boldSystemFont(ofSize: 20)
        actionsTitle.text = "Lối tắt"

        let actionsStack = UIStackView()
        actionsStack.axis = .vertical
        actionsStack.spacing = 12

        actionsStack.addArrangedSubview(makeActionButton(title: "Đặt sân ngay", storyboardID: "NewCourtBookingVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Xem lịch thanh toán", storyboardID: "PaymentVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Mở lịch chọn ngày", storyboardID: "CalendarVC"))

        courtsStack.addArrangedSubview(actionsTitle)
        courtsStack.addArrangedSubview(actionsStack)
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

    private func renderCourts(_ courts: [BackendCourtCard]) {
        courtsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard !courts.isEmpty else {
            courtsStack.addArrangedSubview(makeStateLabel(text: "Chưa có sân nào từ backend."))
            return
        }

        for court in courts.prefix(5) {
            let card = UIStackView()
            card.axis = .vertical
            card.spacing = 6
            card.backgroundColor = .secondarySystemBackground
            card.layer.cornerRadius = 16
            card.isLayoutMarginsRelativeArrangement = true
            card.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)

            let title = UILabel()
            title.font = .systemFont(ofSize: 17, weight: .semibold)
            title.text = court.name

            let detail = UILabel()
            detail.font = .systemFont(ofSize: 14)
            detail.textColor = .secondaryLabel
            detail.numberOfLines = 0
            detail.text = "\(court.type) • \(court.status) • \(court.priceText)/giờ"

            card.addArrangedSubview(title)
            card.addArrangedSubview(detail)
            courtsStack.addArrangedSubview(card)
        }
    }

    private func renderCourtsError(_ message: String) {
        courtsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        courtsStack.addArrangedSubview(makeStateLabel(text: "Không tải được danh sách sân: \(message)"))
    }

    private func makeStateLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = text
        return label
    }

    private func makeActionButton(title: String, storyboardID: String) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = .systemMint
        configuration.baseForegroundColor = .label
        button.configuration = configuration
        button.addAction(UIAction { [weak self] _ in
            self?.openScreen(with: storyboardID)
        }, for: .touchUpInside)
        return button
    }

    private func openScreen(with storyboardID: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardID)
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    @IBAction private func notificationButtonTapped(_ sender: UIButton) {
        openScreen(with: "NotificationsVC")
    }
}

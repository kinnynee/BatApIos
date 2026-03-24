import UIKit

final class HomeViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

    override var screenTitleText: String {
        "Xin chào, \(store.currentUser?.username ?? "người chơi")"
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
        configureQuickActions()
    }

    private func configureQuickActions() {
        guard let contentStack = view.subviews.compactMap({ $0 as? UIStackView }).first else { return }

        let actionsTitle = UILabel()
        actionsTitle.font = .boldSystemFont(ofSize: 20)
        actionsTitle.text = "Lối tắt"

        let actionsStack = UIStackView()
        actionsStack.axis = .vertical
        actionsStack.spacing = 12

        actionsStack.addArrangedSubview(makeActionButton(title: "Đặt sân ngay", storyboardID: "NewCourtBookingVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Xem lịch thanh toán", storyboardID: "PaymentVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Mở lịch chọn ngày", storyboardID: "CalendarVC"))

        contentStack.addArrangedSubview(actionsTitle)
        contentStack.addArrangedSubview(actionsStack)
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

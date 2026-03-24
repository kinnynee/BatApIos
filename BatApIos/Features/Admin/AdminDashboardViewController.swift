import UIKit

final class AdminDashboardViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

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
        configureAdminActions()
    }

    private func currencyText(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0 đ"
    }

    private func configureAdminActions() {
        guard let contentStack = view.subviews.compactMap({ $0 as? UIStackView }).first else { return }

        let actionsTitle = UILabel()
        actionsTitle.font = .boldSystemFont(ofSize: 20)
        actionsTitle.text = "Điều hướng quản trị"

        let actionsStack = UIStackView()
        actionsStack.axis = .vertical
        actionsStack.spacing = 12

        actionsStack.addArrangedSubview(makeActionButton(title: "Báo cáo doanh thu", storyboardID: "RevenueReportVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Nhật ký hệ thống", storyboardID: "SystemLogsVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Check-in staff", storyboardID: "StaffCheckInVC"))

        contentStack.addArrangedSubview(actionsTitle)
        contentStack.addArrangedSubview(actionsStack)
    }

    private func makeActionButton(title: String, storyboardID: String) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
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
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
}

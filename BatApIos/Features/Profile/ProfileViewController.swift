import UIKit

final class ProfileViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var bookingsCountLabel: UILabel!
    @IBOutlet private weak var bookingsSubtitleLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var membershipLabel: UILabel!

    override var screenTitleText: String {
        store.currentUser?.username ?? "Hồ sơ cá nhân"
    }

    override var screenSubtitleText: String {
        "Email: \(store.currentUser?.email ?? "Chưa có email"). Vai trò: \(store.currentUser?.role.rawValue ?? "Unknown")."
    }

    override var screenHighlights: [String] {
        [
            "Membership: \(store.membershipSummary())",
            "Booking gần nhất: \(store.latestBookingSummary())",
            "Thông báo hiện có: \(store.notificationsForCurrentUser().count)"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindProfileData()
        configureProfileActions()
    }

    private func bindProfileData() {
        let user = store.currentUser
        nameLabel?.text = user?.username ?? "Hồ sơ cá nhân"
        subtitleLabel?.text = user?.email ?? "Chưa có email"
        bookingsCountLabel?.text = "\(store.bookingCount())"

        if let latestBooking = store.latestBooking() {
            bookingsSubtitleLabel?.text = latestBooking.id
        } else {
            bookingsSubtitleLabel?.text = "Chưa có booking"
        }

        let points = Int((user?.walletBalance ?? 0) / 100)
        pointsLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: points), number: .decimal)
        membershipLabel?.text = store.membershipSummary().components(separatedBy: " • ").first ?? "Standard"
    }

    private func configureProfileActions() {
        guard let contentStack = view.subviews.compactMap({ $0 as? UIStackView }).first else { return }

        let actionsTitle = UILabel()
        actionsTitle.font = .boldSystemFont(ofSize: 20)
        actionsTitle.text = "Quản lý tài khoản"

        let actionsStack = UIStackView()
        actionsStack.axis = .vertical
        actionsStack.spacing = 12

        actionsStack.addArrangedSubview(makeActionButton(title: "Thông báo", storyboardID: "NotificationsVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Đổi mật khẩu", storyboardID: "ChangeVC"))
        actionsStack.addArrangedSubview(makeActionButton(title: "Về ứng dụng", storyboardID: "AboutVC"))
        actionsStack.addArrangedSubview(makeLogoutButton())

        contentStack.addArrangedSubview(actionsTitle)
        contentStack.addArrangedSubview(actionsStack)
    }

    private func makeActionButton(title: String, storyboardID: String) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.tinted()
        configuration.title = title
        configuration.cornerStyle = .large
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

    private func makeLogoutButton() -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Đăng xuất"
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = .systemRed
        configuration.baseForegroundColor = .white
        button.configuration = configuration
        button.addAction(UIAction { [weak self] _ in
            self?.performLogout()
        }, for: .touchUpInside)
        return button
    }

    private func performLogout() {
        let alert = UIAlertController(
            title: "Đăng xuất",
            message: "Bạn có chắc muốn đăng xuất khỏi tài khoản hiện tại?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Đăng xuất", style: .destructive) { [weak self] _ in
            self?.store.logout()
            self?.routeToLogin()
        })
        present(alert, animated: true)
    }

    @IBAction private func logoutButtonTapped(_ sender: UIButton) {
        performLogout()
    }

    private func routeToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")

        guard
            let scene = view.window?.windowScene,
            let windowSceneDelegate = scene.delegate as? SceneDelegate,
            let window = windowSceneDelegate.window
        else {
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true)
            return
        }

        window.rootViewController = loginViewController
        window.makeKeyAndVisible()
    }
}

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bookingsCountLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // Menu Views (For Taps)
    @IBOutlet weak var editInfoView: UIView!
    @IBOutlet weak var paymentMethodsView: UIView!
    @IBOutlet weak var notificationsView: UIView!
    
    // MARK: - Properties
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let store = AppMockStore.shared

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuth()
    }

    private func checkAuth() {
        if store.currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            
            loginVC.onLoginSuccess = { [weak self, weak loginVC] in
                loginVC?.dismiss(animated: true) {
                    self?.loadUserData()
                }
            }
            
            present(loginVC, animated: true)
        }
    }

    private func setupUI() {
        // Style Avatar
        avatarImageView.layer.cornerRadius = 64
        avatarImageView.layer.borderWidth = 4
        avatarImageView.layer.borderColor = themeGreen.withAlphaComponent(0.2).cgColor
        
        // Style Buttons
        editButton.tintColor = themeGreen
        editButton.addTarget(self, action: #selector(editInfoTapped), for: .touchUpInside)
        
        // Add Tap Gestures to menu items
        let editTap = UITapGestureRecognizer(target: self, action: #selector(editInfoTapped))
        editInfoView?.addGestureRecognizer(editTap)
        configureMenuRow(in: editInfoView, iconName: "person", title: "Tài khoản", showsSeparator: true)
        
        let paymentTap = UITapGestureRecognizer(target: self, action: #selector(paymentMethodsTapped))
        paymentMethodsView?.addGestureRecognizer(paymentTap)
        configureMenuRow(in: paymentMethodsView, iconName: "creditcard", title: "Hình thức thanh toán", showsSeparator: true)
        
        let notifyTap = UITapGestureRecognizer(target: self, action: #selector(notificationsTapped))
        notificationsView?.addGestureRecognizer(notifyTap)
        configureMenuRow(in: notificationsView, iconName: "bell", title: "Thông báo", showsSeparator: false)
    }

    private func loadUserData() {
        guard let user = store.currentUser else {
            nameLabel.text = "Khách"
            subtitleLabel.text = "Vui lòng đăng nhập"
            bookingsCountLabel.text = "0"
            pointsLabel.text = "0"
            return
        }

        nameLabel.text = user.username
        subtitleLabel.text = user.email
        
        // Stats
        let bookings = store.paymentHistory().count
        bookingsCountLabel.text = "\(bookings)"
        pointsLabel.text = "1.250"
    }

    // MARK: - Actions
    @objc private func editInfoTapped() {
        let actionSheet = UIAlertController(
            title: "Tài khoản",
            message: "Chọn chức năng bạn muốn mở.",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Đổi mật khẩu", style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "showChangePassword", sender: self)
        }))
        actionSheet.addAction(UIAlertAction(title: "Về ứng dụng", style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "showAbout", sender: self)
        }))
        actionSheet.addAction(UIAlertAction(title: "Chỉnh sửa thông tin", style: .default, handler: { [weak self] _ in
            self?.presentComingSoonAlert()
        }))
        actionSheet.addAction(UIAlertAction(title: "Hủy", style: .cancel))

        if let popover = actionSheet.popoverPresentationController {
            let sourceView: UIView = editInfoView ?? editButton
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }

        present(actionSheet, animated: true)
    }

    @objc private func paymentMethodsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as? PaymentViewController else {
            return
        }

        if let navigationController {
            navigationController.pushViewController(paymentVC, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: paymentVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }

    @objc private func notificationsTapped() {
        performSegue(withIdentifier: "showNotifications", sender: self)
    }

    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Đăng xuất", message: "Bạn có chắc chắn muốn đăng xuất không?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Đăng xuất", style: .destructive, handler: { _ in
            self.performSegue(withIdentifier: "logout", sender: self)
        }))
        present(alert, animated: true)
    }

    private func presentComingSoonAlert() {
        let alert = UIAlertController(
            title: "Chỉnh sửa",
            message: "Tính năng chỉnh sửa thông tin sẽ sớm ra mắt!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func configureMenuRow(in container: UIView?, iconName: String, title: String, showsSeparator: Bool) {
        guard let container else { return }

        container.subviews.forEach { $0.removeFromSuperview() }
        container.backgroundColor = .clear

        let iconBackgroundView = UIView()
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = themeGreen.withAlphaComponent(0.12)
        iconBackgroundView.layer.cornerRadius = 18

        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = themeGreen
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)

        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.tintColor = .systemGray3
        chevronImageView.contentMode = .scaleAspectFit

        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        separatorView.isHidden = !showsSeparator

        container.addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(chevronImageView)
        container.addSubview(separatorView)

        NSLayoutConstraint.activate([
            iconBackgroundView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconBackgroundView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 36),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 36),

            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -12),

            chevronImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),

            separatorView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 64),
            separatorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

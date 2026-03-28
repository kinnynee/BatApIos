
import UIKit

final class AdminDashboardViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    
    // Check-in Section
    @IBOutlet weak var checkInCard: UIControl!
    
    // Stats & Revenue (Admin Only)
    @IBOutlet weak var statsSection: UIView!
    @IBOutlet weak var statsCard: UIView!
    @IBOutlet weak var revenueSection: UIView!
    @IBOutlet weak var revenueCard: UIView!
    
    // Quick Actions
    @IBOutlet weak var bookingsCard: UIControl!
    @IBOutlet weak var staffCard: UIControl!
    @IBOutlet weak var maintenanceCard: UIControl!
    @IBOutlet weak var courtCard: UIControl!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        applyRolePermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)
        
        let user = AppMockStore.shared.currentUser
        nameLabel.text = user?.username ?? "Management"
        configureDashboardCards()
    }
    
    private func applyRolePermissions() {
        let isAdmin = AppMockStore.shared.currentUser?.role == .admin
        
        // Hide/Show sections based on role
        statsSection?.isHidden = !isAdmin
        revenueSection?.isHidden = !isAdmin
        staffCard?.isHidden = !isAdmin
        courtCard?.isHidden = !isAdmin
        
        // Staff sees Check-in and Bookings most prominently
        if !isAdmin {
            nameLabel.text = "Staff: \(AppMockStore.shared.currentUser?.username ?? "Member")"
        }
    }
    
    private func setupGestures() {
        // Check-in
        let checkInTap = UITapGestureRecognizer(target: self, action: #selector(checkInTapped))
        checkInCard?.addGestureRecognizer(checkInTap)
        checkInCard?.isUserInteractionEnabled = true
        
        // Quick Action Cards
        bookingsCard?.addTarget(self, action: #selector(bookingsTapped), for: .touchUpInside)
        staffCard?.addTarget(self, action: #selector(staffTapped), for: .touchUpInside)
        maintenanceCard?.addTarget(self, action: #selector(maintenanceTapped), for: .touchUpInside)
        courtCard?.addTarget(self, action: #selector(courtsTapped), for: .touchUpInside)
        
        // Section Taps for Detail
        statsCard?.isUserInteractionEnabled = true
        let statsTap = UITapGestureRecognizer(target: self, action: #selector(statsCardTapped))
        statsCard?.addGestureRecognizer(statsTap)
        
        revenueCard?.isUserInteractionEnabled = true
        let revTap = UITapGestureRecognizer(target: self, action: #selector(revenueCardTapped))
        revenueCard?.addGestureRecognizer(revTap)

        wireBottomNavigationButtons()
    }

    private func configureDashboardCards() {
        configureCard(
            checkInCard,
            iconName: "qrcode.viewfinder",
            title: "Check-in",
            subtitle: "Xác nhận khách vào sân bằng mã booking."
        )
        configureCard(
            bookingsCard,
            iconName: "calendar.badge.clock",
            title: "Đặt sân",
            subtitle: "Theo dõi danh sách booking và trạng thái."
        )
        configureCard(
            staffCard,
            iconName: "person.2.fill",
            title: "Nhân sự",
            subtitle: "Quản lý tài khoản admin và staff."
        )
        configureCard(
            maintenanceCard,
            iconName: "wrench.and.screwdriver.fill",
            title: "Hệ thống",
            subtitle: "Xem lịch sử hoạt động và bảo trì."
        )
        configureCard(
            courtCard,
            iconName: "figure.badminton",
            title: "Sân",
            subtitle: "Chỉnh sửa danh sách sân và trạng thái."
        )
        configureInfoCard(
            statsCard,
            title: "Tổng quan",
            subtitle: "Theo dõi số booking, check-in và hiệu suất hôm nay."
        )
        configureInfoCard(
            revenueCard,
            title: "Doanh thu",
            subtitle: "Xem tổng tiền, giao dịch và báo cáo thanh toán."
        )
    }

    private func configureCard(_ container: UIView?, iconName: String, title: String, subtitle: String) {
        guard let container else { return }
        container.subviews.forEach { $0.removeFromSuperview() }
        container.layer.cornerRadius = 20
        container.backgroundColor = .systemBackground

        let iconWrap = UIView()
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        iconWrap.layer.cornerRadius = 20

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = subtitle

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.tintColor = .systemGray3

        container.addSubview(iconWrap)
        iconWrap.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(chevronView)

        NSLayoutConstraint.activate([
            iconWrap.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconWrap.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconWrap.widthAnchor.constraint(equalToConstant: 40),
            iconWrap.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            chevronView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 14),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -14)
        ])
    }

    private func configureInfoCard(_ container: UIView?, title: String, subtitle: String) {
        guard let container else { return }
        container.subviews.forEach { $0.removeFromSuperview() }
        container.layer.cornerRadius = 24
        container.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = subtitle

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -18)
        ])
    }

    private func wireBottomNavigationButtons() {
        for button in view.allSubviews(ofType: UIButton.self) {
            guard let title = button.currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }

            switch title {
            case "Sân", "Trạng thái":
                button.addTarget(self, action: #selector(bottomStatusTapped), for: .touchUpInside)
            case "Nhân sự":
                button.addTarget(self, action: #selector(bottomStaffTapped), for: .touchUpInside)
            case "Cài đặt":
                button.addTarget(self, action: #selector(bottomSettingsTapped), for: .touchUpInside)
            default:
                continue
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logoutTapped(_ sender: Any) {
        AppMockStore.shared.logout()
        dismiss(animated: true)
    }
    
    @objc private func checkInTapped() {
        print("Check-in tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StaffCheckInVC") as? StaffCheckInViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func bookingsTapped() {
        print("Bookings tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "BookingManagementVC") as? BookingManagementViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func staffTapped() {
        print("Staff tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StaffManagementVC") as? StaffManagementViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func maintenanceTapped() {
        print("Maintenance tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "MaintenanceVC") as? MaintenanceViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func courtsTapped() {
        print("Courts tapped")
        let vc = CourtManagementViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func statsCardTapped() {
        print("Stats details tapped")
    }

    @objc private func bottomStatusTapped() {
        courtsTapped()
    }

    @objc private func bottomStaffTapped() {
        staffTapped()
    }

    @objc private func bottomSettingsTapped() {
        maintenanceTapped()
    }
    
    @objc private func revenueCardTapped() {
        print("Revenue details tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "RevenueReportVC") as? RevenueReportViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

private extension UIView {
    func allSubviews<T: UIView>(ofType type: T.Type) -> [T] {
        var matches = subviews.compactMap { $0 as? T }
        for subview in subviews {
            matches.append(contentsOf: subview.allSubviews(ofType: type))
        }
        return matches
    }
}

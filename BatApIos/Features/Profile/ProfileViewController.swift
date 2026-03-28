import PhotosUI
import UIKit

final class ProfileViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared
    private let authService = BackendAuthService.shared
    private let bookingsService = BackendBookingsService.shared

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var bookingsCountLabel: UILabel!
    @IBOutlet private weak var bookingsSubtitleLabel: UILabel!
    @IBOutlet private weak var pointsLabel: UILabel!
    @IBOutlet private weak var membershipLabel: UILabel!

    override var screenTitleText: String {
        authService.restorePersistedUser()?.username ?? store.currentUser?.username ?? "Hồ sơ cá nhân"
    }

    override var screenSubtitleText: String {
        let persistedUser = authService.restorePersistedUser()
        let email = persistedUser?.email ?? store.currentUser?.email ?? "Chưa có email"
        let role = persistedUser?.role.rawValue ?? store.currentUser?.role.rawValue ?? "Unknown"
        return "Email: \(email). Vai trò: \(role)."
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
        configureAvatarUI()
        bindProfileData()
        configureProfileActions()
        loadBackendProfileData()
    }

    private func bindProfileData() {
        let user = authService.restorePersistedUser() ?? store.currentUser
        applyPersistedAvatarIfAvailable(for: user)
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

    private func loadBackendProfileData() {
        guard let currentUser = authService.restorePersistedUser(), let uid = currentUser.id else { return }

        Task { [weak self] in
            guard let self else { return }

            do {
                async let profileTask = authService.getProfile(uid: uid)
                async let bookingsTask = bookingsService.fetchBookings(userId: uid)

                let (profile, bookings) = try await (profileTask, bookingsTask)

                await MainActor.run {
                    self.applyBackendProfile(profile, bookings: bookings, fallbackUser: currentUser)
                }
            } catch {
                await MainActor.run {
                    self.subtitleLabel?.text = currentUser.email
                }
            }
        }
    }

    private func applyBackendProfile(
        _ profile: BackendLoginProfile,
        bookings: [BackendBookingRecord],
        fallbackUser: User
    ) {
        let displayName = profile.fullName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayEmail = profile.email?.trimmingCharacters(in: .whitespacesAndNewlines)
        let roleText = profile.role?.trimmingCharacters(in: .whitespacesAndNewlines)

        nameLabel?.text = (displayName?.isEmpty == false ? displayName : fallbackUser.username) ?? "Hồ sơ cá nhân"

        let subtitleParts = [
            (displayEmail?.isEmpty == false ? displayEmail : fallbackUser.email),
            roleText?.isEmpty == false ? "Vai trò: \(roleText!)" : nil
        ].compactMap { $0 }
        subtitleLabel?.text = subtitleParts.joined(separator: " • ")

        bookingsCountLabel?.text = "\(bookings.count)"
        if let latestBooking = bookings.first {
            bookingsSubtitleLabel?.text = "\(latestBooking.bookingCode) • \(latestBooking.bookingDate)"
        } else {
            bookingsSubtitleLabel?.text = "Chưa có booking"
        }

        let derivedPoints = bookings.count * 120
        pointsLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: derivedPoints), number: .decimal)
        membershipLabel?.text = membershipTitle(for: bookings.count)
    }

    private func configureAvatarUI() {
        avatarImageView?.clipsToBounds = true
        avatarImageView?.isUserInteractionEnabled = true
        avatarImageView?.contentMode = .scaleAspectFill

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeAvatarTapped(_:)))
        avatarImageView?.addGestureRecognizer(tapGesture)
    }

    private func applyPersistedAvatarIfAvailable(for user: User?) {
        guard let avatarImageView else { return }

        if
            let user,
            let avatarData = UserDefaults.standard.data(forKey: avatarStorageKey(for: user)),
            let image = UIImage(data: avatarData)
        {
            avatarImageView.image = image
            avatarImageView.tintColor = nil
        } else {
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = UIColor(white: 0.67, alpha: 1)
        }
    }

    private func avatarStorageKey(for user: User) -> String {
        let identity = user.id ?? user.email.lowercased()
        return "batapp.profile.avatar.\(identity)"
    }

    private func persistAvatar(_ image: UIImage, for user: User) {
        let resizedImage = resizedAvatarImage(from: image)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.82) else { return }

        UserDefaults.standard.set(imageData, forKey: avatarStorageKey(for: user))
        avatarImageView?.image = resizedImage
        avatarImageView?.tintColor = nil
    }

    private func resizedAvatarImage(from image: UIImage) -> UIImage {
        let targetSize = CGSize(width: 320, height: 320)
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            let aspectWidth = targetSize.width / max(image.size.width, 1)
            let aspectHeight = targetSize.height / max(image.size.height, 1)
            let aspectRatio = max(aspectWidth, aspectHeight)
            let scaledSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            let drawRect = CGRect(
                x: (targetSize.width - scaledSize.width) / 2,
                y: (targetSize.height - scaledSize.height) / 2,
                width: scaledSize.width,
                height: scaledSize.height
            )
            image.draw(in: drawRect)
        }
    }

    @IBAction private func changeAvatarTapped(_ sender: Any) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func membershipTitle(for bookingsCount: Int) -> String {
        switch bookingsCount {
        case 10...:
            return "Gold"
        case 5...:
            return "Silver"
        default:
            return "Standard"
        }
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
            BackendAuthService.shared.clearSession()
            try? FirebaseAuthService.shared.signOut()
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

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard
            let result = results.first,
            result.itemProvider.canLoadObject(ofClass: UIImage.self),
            let currentUser = authService.restorePersistedUser() ?? store.currentUser
        else {
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                self.persistAvatar(image, for: currentUser)
            }
        }
    }
}

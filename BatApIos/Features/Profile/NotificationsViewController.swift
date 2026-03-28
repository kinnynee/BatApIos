import UIKit

final class NotificationsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Notification Row 1
    @IBOutlet weak var row1Title: UILabel!
    @IBOutlet weak var row1Sub: UILabel!
    
    // Notification Row 2
    @IBOutlet weak var row2Title: UILabel!
    @IBOutlet weak var row2Sub: UILabel!

    private let contentStackView = UIStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadNotifications()
    }

    private func setupUI() {
        titleLabel.text = "Thông báo"
        rebuildNotificationLayoutIfNeeded()
    }

    private func loadNotifications() {
        let notifications: [(String, String, String)] = [
            ("checkmark.circle.fill", "Sân đã đặt thành công", "Giao dịch đặt sân Sân Cầu Lông CodeForApp lúc 18:00 đã hoàn tất."),
            ("clock.badge.checkmark.fill", "Nhắc nhở lịch đặt", "Bạn có lịch chơi cầu lông vào lúc 20:00 tối nay. Đừng quên nhé!")
        ]

        if contentStackView.superview != nil {
            contentStackView.arrangedSubviews.forEach {
                contentStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

            notifications.forEach { iconName, title, message in
                contentStackView.addArrangedSubview(makeNotificationCard(iconName: iconName, title: title, message: message))
            }
        } else {
            row1Title.text = notifications[0].1
            row1Sub.text = notifications[0].2
            row2Title.text = notifications[1].1
            row2Sub.text = notifications[1].2
        }
    }

    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func rebuildNotificationLayoutIfNeeded() {
        guard let rootView = view else { return }
        let shouldOverlay = rootView.subviews.contains { $0 !== backButton && $0 !== titleLabel }
        guard shouldOverlay else { return }

        rootView.subviews.forEach { subview in
            if subview !== backButton && subview !== titleLabel {
                subview.isHidden = true
            }
        }

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        rootView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -24)
        ])
    }

    private func makeNotificationCard(iconName: String, title: String, message: String) -> UIView {
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 18

        let iconWrap = UIView()
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        iconWrap.layer.cornerRadius = 22

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = title

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.text = message

        cardView.addSubview(iconWrap)
        iconWrap.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            iconWrap.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconWrap.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            iconWrap.widthAnchor.constraint(equalToConstant: 44),
            iconWrap.heightAnchor.constraint(equalToConstant: 44),

            iconView.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),

            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            messageLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        return cardView
    }
}

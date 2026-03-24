import UIKit

final class SystemLogsViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

    override var screenTitleText: String {
        "System Logs"
    }

    override var screenSubtitleText: String {
        "Màn hình kiểm tra các sự kiện hệ thống, giao dịch và lỗi vận hành."
    }

    override var screenHighlights: [String] {
        [
            "Lọc log theo thời gian",
            "Theo dõi check-in, booking và thanh toán",
            "Số log hiện tại: \(store.systemLogs().count)"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLogsUI()
    }

    private func configureLogsUI() {
        let logs = store.systemLogs()
        guard !logs.isEmpty else { return }

        view.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 0
        titleLabel.text = screenTitleText

        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Nhật ký hệ thống mới nhất từ các thao tác auth, booking và payment trong session demo."

        let logsStack = UIStackView()
        logsStack.axis = .vertical
        logsStack.spacing = 10
        logsStack.translatesAutoresizingMaskIntoConstraints = false

        logs.prefix(6).forEach { item in
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.textColor = .label
            label.numberOfLines = 0
            label.text = "• \(item.title): \(item.message)"
            logsStack.addArrangedSubview(label)
        }

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 18
        container.addSubview(logsStack)

        NSLayoutConstraint.activate([
            logsStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            logsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            logsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            logsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])

        let rootStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, container])
        rootStack.axis = .vertical
        rootStack.spacing = 16
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            rootStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            rootStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
}

import UIKit

final class AboutViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

    private let overlayScrollView = UIScrollView()
    private let overlayStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        rebuildAboutLayout()
    }

    override var screenTitleText: String {
        AppLocalization.localized(vi: "Về ứng dụng", en: "About")
    }

    override var screenSubtitleText: String {
        AppLocalization.localized(
            vi: "Màn hình giới thiệu về nhóm, sản phẩm và phạm vi hệ thống.",
            en: "This screen introduces the team, product, and system scope."
        )
    }

    override var screenHighlights: [String] {
        [
            AppLocalization.localized(vi: "Thông tin nhóm phát triển", en: "Development team information"),
            AppLocalization.localized(vi: "Phiên bản demo nội bộ: 1.0", en: "Internal demo version: 1.0"),
            AppLocalization.localized(vi: "Số người dùng mẫu đã nạp", en: "Loaded sample users") + ": \(store.userCount())"
        ]
    }

    private func rebuildAboutLayout() {
        guard let rootView = view else { return }

        rootView.subviews.forEach { $0.isHidden = true }

        overlayScrollView.translatesAutoresizingMaskIntoConstraints = false
        overlayStackView.translatesAutoresizingMaskIntoConstraints = false
        overlayStackView.axis = .vertical
        overlayStackView.spacing = 20

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 30)
        titleLabel.numberOfLines = 0
        titleLabel.text = screenTitleText

        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = screenSubtitleText

        let versionCard = makeCard(
            title: AppLocalization.localized(vi: "Phiên bản", en: "Version"),
            detail: "BatAp iOS Demo • v1.0"
        )
        let teamCard = makeCard(
            title: AppLocalization.localized(vi: "Nhóm phát triển", en: "Development Team"),
            detail: AppLocalization.localized(
                vi: "Ứng dụng đặt sân, thanh toán, lịch đặt và check-in cho người chơi cầu lông.",
                en: "Court booking, payment, schedule, and check-in app for badminton players."
            )
        )
        let featuresCard = makeBulletCard(title: AppLocalization.localized(vi: "Tính năng chính", en: "Key Features"), items: screenHighlights)

        rootView.addSubview(overlayScrollView)
        overlayScrollView.addSubview(overlayStackView)
        [titleLabel, subtitleLabel, versionCard, teamCard, featuresCard].forEach { overlayStackView.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            overlayScrollView.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            overlayScrollView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            overlayScrollView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            overlayScrollView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),

            overlayStackView.topAnchor.constraint(equalTo: overlayScrollView.contentLayoutGuide.topAnchor, constant: 24),
            overlayStackView.leadingAnchor.constraint(equalTo: overlayScrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            overlayStackView.trailingAnchor.constraint(equalTo: overlayScrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            overlayStackView.bottomAnchor.constraint(equalTo: overlayScrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            overlayStackView.widthAnchor.constraint(equalTo: overlayScrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    private func makeCard(title: String, detail: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 18

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.text = title

        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.text = detail

        card.addSubview(titleLabel)
        card.addSubview(detailLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }

    private func makeBulletCard(title: String, items: [String]) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 18

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.text = title
        card.addSubview(titleLabel)

        var previousView: UIView = titleLabel
        for item in items {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = .label
            label.numberOfLines = 0
            label.text = "• \(item)"
            card.addSubview(label)

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 10),
                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16)
            ])
            previousView = label
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            previousView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }
}

import UIKit

class StoryboardScreenViewController: UIViewController {

    var screenTitleText: String {
        title ?? String(describing: type(of: self)).replacingOccurrences(of: "ViewController", with: "")
    }

    var screenSubtitleText: String {
        AppLocalization.localized(
            vi: "Màn hình này đã có controller riêng và sẵn sàng để nối nghiệp vụ demo.",
            en: "This screen already has its own controller and is ready for demo business logic."
        )
    }

    var screenHighlights: [String] {
        []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = view.backgroundColor ?? .systemBackground
        configurePlaceholderUIIfNeeded()
    }

    private func configurePlaceholderUIIfNeeded() {
        guard view.subviews.isEmpty else { return }

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.text = screenTitleText

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = screenSubtitleText

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12

        if !screenHighlights.isEmpty {
            let featuresContainer = UIStackView()
            featuresContainer.translatesAutoresizingMaskIntoConstraints = false
            featuresContainer.axis = .vertical
            featuresContainer.spacing = 10

            for highlight in screenHighlights {
                let label = UILabel()
                label.font = .systemFont(ofSize: 15, weight: .medium)
                label.textColor = .label
                label.numberOfLines = 0
                label.text = "• \(highlight)"
                featuresContainer.addArrangedSubview(label)
            }

            let cardView = UIView()
            cardView.translatesAutoresizingMaskIntoConstraints = false
            cardView.backgroundColor = .secondarySystemBackground
            cardView.layer.cornerRadius = 18
            cardView.addSubview(featuresContainer)

            NSLayoutConstraint.activate([
                featuresContainer.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
                featuresContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                featuresContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
                featuresContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
            ])

            stackView.addArrangedSubview(cardView)
        }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

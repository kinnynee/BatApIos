import UIKit

final class DiscoverViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var bellButton: UIButton!
    
    // Cards for filtering demo
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    @IBOutlet weak var offer1View: UIView!
    @IBOutlet weak var offer2View: UIView!
    @IBOutlet weak var offer3View: UIView!
    
    // Labels
    @IBOutlet weak var nameLabel: UILabel!
    private let store = AppStore.shared
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let themeDark = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        updateGreeting()
        
        // Search Setup
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        
        // Bell Icon Color
        bellButton.tintColor = .black

        configureHomeCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGreeting()
        configureHomeCards()
    }

    // MARK: - Actions
    @objc private func searchTextChanged(_ textField: UITextField) {
        guard let text = textField.text?.lowercased(), !text.isEmpty else {
            card1View.alpha = 1.0
            card2View.alpha = 1.0
            return
        }
        
        // Simple mock filtering logic
        let card1Match = "sân cầu lông codeforapp".contains(text)
        let card2Match = "clb cầu lông năng khiếu".contains(text)
        
        UIView.animate(withDuration: 0.3) {
            self.card1View.alpha = card1Match ? 1.0 : 0.2
            self.card2View.alpha = card2Match ? 1.0 : 0.2
        }
    }

    @IBAction func bellTapped(_ sender: Any) {
        let bookingsViewController = MyBookingsViewController()
        if let navigationController {
            navigationController.pushViewController(bookingsViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: bookingsViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    // Maintain legacy demo button action if needed from storyboard
    @IBAction func openCourtDetailDemo(_ sender: Any) {
        let vc = CourtDetailsVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func updateGreeting() {
        nameLabel.text = store.currentUser?.username ?? "Khách"
    }

    private func configureHomeCards() {
        let featuredCourt = store.featuredCourts().first
        let promotion = store.activePromotion()
        let promotions = store.availablePromotions()

        configureCard(
            card1View,
            title: featuredCourt?.name ?? "Chưa có sân",
            subtitle: featuredCourt.map { "\($0.type.rawValue) • \(Int($0.pricePerHour)) đ/giờ" } ?? "Chưa có dữ liệu sân từ hệ thống.",
            accentText: featuredCourt == nil ? "Đang cập nhật" : "Xem sân",
            accentColor: themeGreen,
            iconName: "figure.badminton",
            selector: #selector(openFeaturedCourt)
        )

        configureCard(
            card2View,
            title: promotion?.title ?? "Chưa có ưu đãi",
            subtitle: promotion?.subtitle ?? "Ưu đãi sẽ hiển thị khi có dữ liệu từ hệ thống.",
            accentText: promotion?.voucherCode ?? "Không có mã",
            accentColor: .systemOrange,
            iconName: "ticket.fill",
            selector: #selector(openPromoBooking)
        )

        let offerViews = [offer1View, offer2View, offer3View]
        for (index, offerView) in offerViews.enumerated() {
            guard let offerView else { continue }
            if promotions.indices.contains(index) {
                let promo = promotions[index]
                configureOfferCard(offerView, promotion: promo, selector: #selector(offerCardTapped(_:)))
                offerView.tag = index
                offerView.isHidden = false
            } else {
                offerView.subviews.forEach { $0.removeFromSuperview() }
                offerView.isHidden = true
            }
        }
    }

    private func configureCard(
        _ card: UIView,
        title: String,
        subtitle: String,
        accentText: String,
        accentColor: UIColor,
        iconName: String,
        selector: Selector
    ) {
        card.subviews.forEach { $0.removeFromSuperview() }
        card.isUserInteractionEnabled = true
        card.gestureRecognizers?.forEach { card.removeGestureRecognizer($0) }
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))

        let iconWrap = UIView()
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = accentColor.withAlphaComponent(0.14)
        iconWrap.layer.cornerRadius = 18

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = themeDark
        titleLabel.numberOfLines = 2
        titleLabel.text = title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 3
        subtitleLabel.text = subtitle

        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        badgeLabel.textColor = accentColor
        badgeLabel.backgroundColor = accentColor.withAlphaComponent(0.1)
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.text = "  \(accentText)  "

        let arrowView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.tintColor = .tertiaryLabel

        card.addSubview(iconWrap)
        iconWrap.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(badgeLabel)
        card.addSubview(arrowView)

        NSLayoutConstraint.activate([
            iconWrap.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            iconWrap.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            iconWrap.widthAnchor.constraint(equalToConstant: 36),
            iconWrap.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: iconWrap.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            badgeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            badgeLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            badgeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),

            arrowView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            arrowView.centerYAnchor.constraint(equalTo: badgeLabel.centerYAnchor)
        ])
    }

    @objc private func openFeaturedCourt() {
        guard store.featuredCourts().isEmpty == false else { return }
        let vc = CourtDetailsVC()
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    @objc private func openPromoBooking() {
        guard let voucherCode = store.activePromotion()?.voucherCode else { return }
        openBooking(prefilledVoucherCode: voucherCode)
    }

    @objc private func offerCardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let promotions = store.availablePromotions()
        guard promotions.indices.contains(index) else { return }
        openBooking(prefilledVoucherCode: promotions[index].voucherCode)
    }

    private func configureOfferCard(_ card: UIView, promotion: PromotionBanner, selector: Selector) {
        card.subviews.forEach { $0.removeFromSuperview() }
        card.isUserInteractionEnabled = true
        card.gestureRecognizers?.forEach { card.removeGestureRecognizer($0) }
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = themeDark
        titleLabel.text = promotion.title

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = promotion.subtitle

        let codeLabel = UILabel()
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        codeLabel.font = .systemFont(ofSize: 12, weight: .bold)
        codeLabel.textColor = themeGreen
        codeLabel.text = promotion.voucherCode

        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = .systemFont(ofSize: 13, weight: .bold)
        amountLabel.textColor = .systemOrange
        amountLabel.text = "-\(Int(promotion.discountAmount))đ"

        let footerStackView = UIStackView(arrangedSubviews: [codeLabel, amountLabel])
        footerStackView.translatesAutoresizingMaskIntoConstraints = false
        footerStackView.axis = .horizontal
        footerStackView.alignment = .center
        footerStackView.distribution = .equalSpacing
        footerStackView.spacing = 12

        [titleLabel, subtitleLabel, footerStackView].forEach { card.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: footerStackView.topAnchor, constant: -10),

            footerStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    private func openBooking(prefilledVoucherCode: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NewCourtBookingVC") as? NewCourtBookingViewController else {
            return
        }
        vc.prefilledVoucherCode = prefilledVoucherCode

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }
}

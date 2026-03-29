import UIKit

final class PaymentTableViewCell: UITableViewCell {

    @IBOutlet private weak var productImageView: UIImageView?
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var priceLabel: UILabel?

    private let cardView = UIView()
    private let iconContainerView = UIView()
    private let fallbackImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let amountLabel = UILabel()
    private let statusLabel = UILabel()
    private let methodLabel = UILabel()

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
        applyBaseStyle()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        fallbackImageView.image = UIImage(systemName: "photo")
        titleLabel.text = nil
        subtitleLabel.text = nil
        amountLabel.text = nil
        statusLabel.text = nil
        methodLabel.text = nil
    }

    func configure(with payment: PaymentInfo) {
        fallbackImageView.image = payment.productImage ?? UIImage(systemName: "photo")
        titleLabel.text = payment.productName
        subtitleLabel.text = payment.subtitle
        amountLabel.text = payment.price
        statusLabel.text = payment.status.title
        statusLabel.textColor = payment.status.tintColor
        methodLabel.text = payment.paymentMethod
    }

    private func setupLayout() {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        [cardView, iconContainerView, fallbackImageView, titleLabel, subtitleLabel, amountLabel, statusLabel, methodLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(cardView)
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(fallbackImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(amountLabel)
        cardView.addSubview(statusLabel)
        cardView.addSubview(methodLabel)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 54),
            iconContainerView.heightAnchor.constraint(equalToConstant: 54),

            fallbackImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            fallbackImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            fallbackImageView.widthAnchor.constraint(equalToConstant: 26),
            fallbackImageView.heightAnchor.constraint(equalToConstant: 26),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -12),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),

            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            amountLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),

            statusLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            statusLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 4),

            methodLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            methodLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            methodLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    private func applyBaseStyle() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 22
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray6.cgColor
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius = 18
        cardView.layer.masksToBounds = false

        iconContainerView.backgroundColor = UIColor(red: 0.92, green: 0.97, blue: 0.95, alpha: 1)
        iconContainerView.layer.cornerRadius = 18

        fallbackImageView.tintColor = UIColor(red: 0.06, green: 0.55, blue: 0.43, alpha: 1)
        fallbackImageView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        amountLabel.font = .boldSystemFont(ofSize: 18)
        amountLabel.textColor = .label
        amountLabel.textAlignment = .right

        statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
        statusLabel.textAlignment = .right

        methodLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        methodLabel.textColor = .secondaryLabel
        methodLabel.textAlignment = .right
    }
}

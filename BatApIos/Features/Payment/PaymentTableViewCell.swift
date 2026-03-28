import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 22
        contentView.layer.masksToBounds = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray6.cgColor

        productImageView.layer.cornerRadius = 18
        productImageView.clipsToBounds = true
        productImageView.backgroundColor = UIColor(red: 0.92, green: 0.97, blue: 0.95, alpha: 1)
        productImageView.tintColor = UIColor(red: 0.06, green: 0.55, blue: 0.43, alpha: 1)
        productImageView.contentMode = .center

        nameLabel.numberOfLines = 2
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .label

        priceLabel.numberOfLines = 3
        priceLabel.textAlignment = .right
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentView.layer.shadowRadius = 18
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = UIImage(systemName: "photo")
        nameLabel.text = nil
        priceLabel.attributedText = nil
    }

    func configure(with payment: PaymentInfo) {
        productImageView.image = payment.productImage ?? UIImage(systemName: "photo")
        let title = NSMutableAttributedString(
            string: payment.productName,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.label
            ]
        )
        title.append(NSAttributedString(
            string: "\n\(payment.subtitle)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ]
        ))
        nameLabel.attributedText = title

        let priceText = NSMutableAttributedString(
            string: payment.price,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.label
            ]
        )
        let detailText = NSAttributedString(
            string: "\n\(payment.status.title)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: payment.status.tintColor
            ]
        )
        let methodText = NSAttributedString(
            string: "\n\(payment.paymentMethod)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        priceText.append(detailText)
        priceText.append(methodText)
        priceLabel.attributedText = priceText
    }
}

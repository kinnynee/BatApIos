import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = UIImage(systemName: "photo")
        nameLabel.text = nil
        priceLabel.text = nil
    }

    func configure(with payment: PaymentInfo) {
        productImageView.image = payment.productImage ?? UIImage(systemName: "photo")
        nameLabel.text = payment.productName
        priceLabel.text = payment.price
    }
}

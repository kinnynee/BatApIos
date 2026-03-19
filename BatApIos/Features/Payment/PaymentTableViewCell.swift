//
//  PaymentTableViewCell.swift
//  BatApIos
//
//  Created by Trần Kiên on 16/3/26.
//
import UIKit

class PaymentTableViewCell: UITableViewCell {
    
    // 1. Các Outlet kết nối từ Storyboard
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    // 2. Hàm này chạy một lần duy nhất khi Cell được tạo ra từ Storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Bạn có thể làm đẹp UI ở đây, ví dụ bo góc cho ảnh sản phẩm
        productImageView.layer.cornerRadius = 8
        productImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = UIImage(systemName: "photo")
        nameLabel.text = nil
        priceLabel.text = nil
    }

    // 3. Hàm cấu hình dữ liệu cho Cell
    // Thay vì set dữ liệu trực tiếp bên ngoài View Controller,
    // ta gom vào đây để code gọn gàng và dễ quản lý tái sử dụng hơn.
    func configure(with payment: PaymentInfo) {
        productImageView.image = payment.productImage ?? UIImage(systemName: "photo")
        nameLabel.text = payment.productName
        priceLabel.text = payment.price
    }
}

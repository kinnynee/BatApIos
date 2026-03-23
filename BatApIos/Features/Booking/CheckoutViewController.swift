import UIKit

final class CheckoutViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Checkout"
    }

    override var screenSubtitleText: String {
        "Tổng hợp lại thông tin sân, thời gian chơi và chi phí trước khi thanh toán."
    }

    override var screenHighlights: [String] {
        [
            "Hiển thị thông tin booking",
            "Áp dụng giảm giá hoặc membership",
            "Đi tiếp tới chọn phương thức thanh toán"
        ]
    }
}

import UIKit

final class NotificationsViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Thông báo"
    }

    override var screenSubtitleText: String {
        "Màn hình hiển thị xác nhận booking, nhắc lịch và thông báo marketing."
    }

    override var screenHighlights: [String] {
        [
            "Xác nhận đặt sân thành công",
            "Nhắc giờ chơi và trạng thái thanh toán",
            "Nhận bản tin khuyến mãi"
        ]
    }
}

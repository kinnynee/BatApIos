import UIKit

final class NewCourtBookingViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Đặt sân mới"
    }

    override var screenSubtitleText: String {
        "Màn hình dành cho thao tác tạo booking nhanh tại quầy hoặc bởi nhân viên."
    }

    override var screenHighlights: [String] {
        [
            "Tạo booking cho khách vãng lai",
            "Chọn sân, giờ chơi và thông tin khách",
            "Chuyển tiếp sang thanh toán hoặc xác nhận"
        ]
    }
}

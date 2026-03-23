import UIKit

final class HomeViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Trang chủ"
    }

    override var screenSubtitleText: String {
        "Điểm vào chính cho người dùng với các lối tắt đặt sân, xem lịch và thông báo."
    }

    override var screenHighlights: [String] {
        [
            "Đi tới đặt sân trực tuyến",
            "Xem lịch đặt gần nhất",
            "Hiển thị ưu đãi hoặc membership"
        ]
    }
}

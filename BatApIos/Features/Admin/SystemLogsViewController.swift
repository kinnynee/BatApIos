import UIKit

final class SystemLogsViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "System Logs"
    }

    override var screenSubtitleText: String {
        "Màn hình kiểm tra các sự kiện hệ thống, giao dịch và lỗi vận hành."
    }

    override var screenHighlights: [String] {
        [
            "Lọc log theo thời gian",
            "Theo dõi check-in, booking và thanh toán",
            "Hỗ trợ debug trong buổi demo"
        ]
    }
}

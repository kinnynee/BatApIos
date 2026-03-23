import UIKit

final class RevenueReportViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Báo cáo doanh thu"
    }

    override var screenSubtitleText: String {
        "Màn hình tổng hợp doanh thu theo ngày, giao dịch và membership."
    }

    override var screenHighlights: [String] {
        [
            "Tổng tiền từ đặt sân",
            "Doanh thu từ thành viên và ưu đãi",
            "Biểu đồ và tóm tắt giao dịch"
        ]
    }
}

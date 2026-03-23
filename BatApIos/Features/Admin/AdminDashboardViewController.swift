import UIKit

final class AdminDashboardViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Admin Dashboard"
    }

    override var screenSubtitleText: String {
        "Màn hình tổng quan cho quản trị viên theo dõi vận hành hệ thống."
    }

    override var screenHighlights: [String] {
        [
            "Tổng doanh thu, số booking và số người dùng",
            "Đi nhanh tới logs, báo cáo và quản lý sân",
            "Theo dõi trạng thái hệ thống theo thời gian thực"
        ]
    }
}

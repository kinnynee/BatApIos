import UIKit

final class CourtsViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Danh sách sân"
    }

    override var screenSubtitleText: String {
        "Màn hình dùng để xem tình trạng sân, loại sân và khả năng đặt."
    }

    override var screenHighlights: [String] {
        [
            "Hiển thị trạng thái trống, đã đặt hoặc bảo trì",
            "Phân loại sân Standard, VIP, Double",
            "Đi tới lịch hoặc đặt sân nhanh"
        ]
    }
}

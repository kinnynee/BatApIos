import UIKit

final class DiscoverViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Khám phá"
    }

    override var screenSubtitleText: String {
        "Màn hình gợi ý sân nổi bật, khuyến mãi và các gói dịch vụ."
    }

    override var screenHighlights: [String] {
        [
            "Sân nổi bật trong ngày",
            "Ưu đãi đặt sân và membership",
            "Lối tắt tới chi tiết sân"
        ]
    }
}

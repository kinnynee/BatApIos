import UIKit

final class AboutViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Về ứng dụng"
    }

    override var screenSubtitleText: String {
        "Màn hình giới thiệu về nhóm, sản phẩm và phạm vi hệ thống."
    }

    override var screenHighlights: [String] {
        [
            "Thông tin nhóm phát triển",
            "Phiên bản ứng dụng",
            "Mô tả tính năng chính"
        ]
    }
}

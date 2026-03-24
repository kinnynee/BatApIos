import UIKit

final class AboutViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

    override var screenTitleText: String {
        "Về ứng dụng"
    }

    override var screenSubtitleText: String {
        "Màn hình giới thiệu về nhóm, sản phẩm và phạm vi hệ thống."
    }

    override var screenHighlights: [String] {
        [
            "Thông tin nhóm phát triển",
            "Phiên bản demo nội bộ: 1.0",
            "Số người dùng mẫu đã nạp: \(store.userCount())"
        ]
    }
}

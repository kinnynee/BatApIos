import UIKit

final class DiscoverViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

    override var screenTitleText: String {
        "Khám phá"
    }

    override var screenSubtitleText: String {
        "Màn hình gợi ý sân nổi bật, khuyến mãi và các gói dịch vụ. Dữ liệu gợi ý đang bám theo booking hiện có của người dùng."
    }

    override var screenHighlights: [String] {
        [
            "Gợi ý đặt lại: \(store.latestBooking()?.courtName ?? "Sân VIP 02")",
            "Ưu đãi ví thành viên: \(store.membershipSummary())",
            "Số thông báo chưa đọc theo session demo: \(store.notificationsForCurrentUser().count)"
        ]
    }
}

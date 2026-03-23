import UIKit

final class ProfileViewController: StoryboardScreenViewController {

    override var screenTitleText: String {
        "Hồ sơ cá nhân"
    }

    override var screenSubtitleText: String {
        "Màn hình quản lý thông tin tài khoản, membership và các tuỳ chọn cá nhân."
    }

    override var screenHighlights: [String] {
        [
            "Xem thông tin cơ bản",
            "Quản lý membership",
            "Đi tới đổi mật khẩu hoặc lịch sử đặt sân"
        ]
    }
}

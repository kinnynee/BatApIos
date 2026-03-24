import UIKit

final class NotificationsViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared
    @IBOutlet private weak var firstTitleLabel: UILabel!
    @IBOutlet private weak var firstSubtitleLabel: UILabel!
    @IBOutlet private weak var secondTitleLabel: UILabel!
    @IBOutlet private weak var secondSubtitleLabel: UILabel!
    @IBOutlet private weak var thirdTitleLabel: UILabel!
    @IBOutlet private weak var thirdSubtitleLabel: UILabel!
    @IBOutlet private weak var fourthTitleLabel: UILabel!
    @IBOutlet private weak var fourthSubtitleLabel: UILabel!
    @IBOutlet private weak var firstSwitch: UISwitch!
    @IBOutlet private weak var secondSwitch: UISwitch!
    @IBOutlet private weak var thirdSwitch: UISwitch!
    @IBOutlet private weak var fourthSwitch: UISwitch!

    override var screenTitleText: String {
        "Thông báo"
    }

    override var screenSubtitleText: String {
        "Màn hình hiển thị xác nhận booking, nhắc lịch và thông báo marketing."
    }

    override var screenHighlights: [String] {
        [
            "Xác nhận đặt sân thành công",
            "Nhắc giờ chơi và trạng thái thanh toán",
            "Số bản tin hiện tại: \(store.notificationsForCurrentUser().count)"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindNotifications()
    }

    private func bindNotifications() {
        let items = store.notificationsForCurrentUser()
        let bookingItems = Array(items.prefix(3))
        let promoItem = items.dropFirst(3).first

        apply(item: bookingItems[safe: 0], titleLabel: firstTitleLabel, subtitleLabel: firstSubtitleLabel, fallbackTitle: "Chưa có thông báo", fallbackSubtitle: "Thông báo xác nhận booking sẽ hiển thị ở đây.")
        apply(item: bookingItems[safe: 1], titleLabel: secondTitleLabel, subtitleLabel: secondSubtitleLabel, fallbackTitle: "Nhắc lịch", fallbackSubtitle: "Thông báo nhắc lịch chơi sẽ hiển thị ở đây.")
        apply(item: bookingItems[safe: 2], titleLabel: thirdTitleLabel, subtitleLabel: thirdSubtitleLabel, fallbackTitle: "Check-in", fallbackSubtitle: "Thông báo check-in sẽ hiển thị ở đây.")
        apply(item: promoItem, titleLabel: fourthTitleLabel, subtitleLabel: fourthSubtitleLabel, fallbackTitle: "Khuyến mãi", fallbackSubtitle: "Tin khuyến mãi và mã giảm giá sẽ hiển thị ở đây.")

        [firstSwitch, secondSwitch, thirdSwitch, fourthSwitch].forEach {
            $0?.isOn = true
        }
    }

    private func apply(item: AppNotificationItem?, titleLabel: UILabel?, subtitleLabel: UILabel?, fallbackTitle: String, fallbackSubtitle: String) {
        titleLabel?.text = item?.title ?? fallbackTitle
        subtitleLabel?.text = item?.message ?? fallbackSubtitle
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

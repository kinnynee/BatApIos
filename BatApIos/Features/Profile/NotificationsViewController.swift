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
        AppLocalization.localized(vi: "Thông báo", en: "Notifications")
    }

    override var screenSubtitleText: String {
        AppLocalization.localized(
            vi: "Màn hình hiển thị xác nhận booking, nhắc lịch và thông báo marketing.",
            en: "This screen shows booking confirmations, reminders, and marketing notifications."
        )
    }

    override var screenHighlights: [String] {
        [
            AppLocalization.localized(vi: "Xác nhận đặt sân thành công", en: "Successful booking confirmation"),
            AppLocalization.localized(vi: "Nhắc giờ chơi và trạng thái thanh toán", en: "Playtime and payment reminders"),
            AppLocalization.localized(vi: "Số bản tin hiện tại", en: "Current notifications") + ": \(store.notificationsForCurrentUser().count)"
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

        apply(item: bookingItems[safe: 0], titleLabel: firstTitleLabel, subtitleLabel: firstSubtitleLabel, fallbackTitle: AppLocalization.localized(vi: "Chưa có thông báo", en: "No notifications"), fallbackSubtitle: AppLocalization.localized(vi: "Thông báo xác nhận booking sẽ hiển thị ở đây.", en: "Booking confirmation notifications will appear here."))
        apply(item: bookingItems[safe: 1], titleLabel: secondTitleLabel, subtitleLabel: secondSubtitleLabel, fallbackTitle: AppLocalization.localized(vi: "Nhắc lịch", en: "Reminder"), fallbackSubtitle: AppLocalization.localized(vi: "Thông báo nhắc lịch chơi sẽ hiển thị ở đây.", en: "Play schedule reminders will appear here."))
        apply(item: bookingItems[safe: 2], titleLabel: thirdTitleLabel, subtitleLabel: thirdSubtitleLabel, fallbackTitle: "Check-in", fallbackSubtitle: AppLocalization.localized(vi: "Thông báo check-in sẽ hiển thị ở đây.", en: "Check-in notifications will appear here."))
        apply(item: promoItem, titleLabel: fourthTitleLabel, subtitleLabel: fourthSubtitleLabel, fallbackTitle: AppLocalization.localized(vi: "Khuyến mãi", en: "Promotions"), fallbackSubtitle: AppLocalization.localized(vi: "Tin khuyến mãi và mã giảm giá sẽ hiển thị ở đây.", en: "Promotions and voucher news will appear here."))

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

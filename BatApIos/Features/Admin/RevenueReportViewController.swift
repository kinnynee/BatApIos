import UIKit

final class RevenueReportViewController: StoryboardScreenViewController {
    private let store = AppMockStore.shared

    override var screenTitleText: String {
        "Báo cáo doanh thu"
    }

    override var screenSubtitleText: String {
        "Màn hình tổng hợp doanh thu theo ngày, giao dịch và membership. Doanh thu hiện tính theo các booking đã thanh toán trong dữ liệu demo."
    }

    override var screenHighlights: [String] {
        [
            "Tổng tiền từ đặt sân: \(currencyText(store.totalRevenue()))",
            "Số giao dịch thành công: \(store.paidBookingCount())",
            "Giá trị booking trung bình: \(averageRevenueText())"
        ]
    }

    private func averageRevenueText() -> String {
        let count = max(store.paidBookingCount(), 1)
        return currencyText(store.totalRevenue() / Double(count))
    }

    private func currencyText(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0 đ"
    }
}

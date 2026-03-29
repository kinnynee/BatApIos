import Foundation
import UIKit

enum OrderStatus: Int {
    case success = 0
    case pending = 1
    case cancelled = 2

    var title: String {
        switch self {
        case .success:
            return AppLocalization.text(.paidStatus)
        case .pending:
            return AppLocalization.text(.pendingStatus)
        case .cancelled:
            return AppLocalization.text(.cancelled)
        }
    }

    var tintColor: UIColor {
        switch self {
        case .success:
            return .systemGreen
        case .pending:
            return .systemOrange
        case .cancelled:
            return .systemRed
        }
    }
}

struct PaymentInfo {
    let bookingId: String
    let productImage: UIImage?
    let productName: String
    let subtitle: String
    let amountValue: Double
    let price: String
    let paymentMethod: String
    let status: OrderStatus
}

struct PaymentSummary {
    let bookingID: String
    let courtName: String
    let scheduleText: String
    let subtotalText: String
    let discountText: String
    let totalText: String
    let status: OrderStatus
    let paymentMethodText: String
}

import Foundation
import UIKit

struct BackendBookingPayload {
    let id: String
    let userId: String
    let courtId: String
    let bookingCode: String
    let bookingDate: String
    let startTime: String
    let endTime: String
    let durationHours: Double
    let pricePerHour: Double
    let totalAmount: Double
    let bookingStatus: String
    let paymentStatus: String
    let createdBy: String
}

struct BackendBookingRecord {
    let id: String
    let bookingCode: String
    let userId: String
    let courtId: String
    let courtName: String
    let bookingDate: String
    let startTime: String
    let endTime: String
    let totalAmount: Double
    let bookingStatus: String
    let paymentStatus: String
}

enum BackendBookingsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidPayload
    case missingUserSession
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL booking backend không hợp lệ."
        case .invalidResponse:
            return "Không nhận được phản hồi hợp lệ từ API booking."
        case .invalidPayload:
            return "Dữ liệu booking trả về không đúng định dạng."
        case .missingUserSession:
            return "Không tìm thấy phiên đăng nhập để tạo booking."
        case .server(let message):
            return message
        }
    }
}

final class BackendBookingsService {
    static let shared = BackendBookingsService()

    private let session: URLSession
    private let baseURL = "http://localhost:3000"

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchBookings(
        userId: String? = nil,
        bookingStatus: String? = nil,
        bookingDate: String? = nil,
        courtId: String? = nil
    ) async throws -> [BackendBookingRecord] {
        var components = URLComponents(string: "\(baseURL)/api/bookings")
        components?.queryItems = [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "bookingStatus", value: bookingStatus),
            URLQueryItem(name: "bookingDate", value: bookingDate),
            URLQueryItem(name: "courtId", value: courtId)
        ].filter { item in
            guard let value = item.value else { return false }
            return !value.isEmpty
        }

        guard let url = components?.url else {
            throw BackendBookingsError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        return try parseBookingsResponse(data: data, response: response)
    }

    func findBooking(by bookingCode: String) async throws -> BackendBookingRecord? {
        let normalizedCode = bookingCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !normalizedCode.isEmpty else { return nil }

        let paidBookings = try await fetchBookings(bookingStatus: "Fully Paid")
        if let exactMatch = paidBookings.first(where: { $0.bookingCode.uppercased() == normalizedCode || $0.id.uppercased() == normalizedCode }) {
            return exactMatch
        }

        let pendingBookings = try await fetchBookings(bookingStatus: "Pending")
        return pendingBookings.first(where: { $0.bookingCode.uppercased() == normalizedCode || $0.id.uppercased() == normalizedCode })
    }

    func createBooking(_ payload: BackendBookingPayload) async throws -> BackendBookingRecord {
        guard let url = URL(string: "\(baseURL)/api/bookings") else {
            throw BackendBookingsError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "id": payload.id,
            "userId": payload.userId,
            "courtId": payload.courtId,
            "bookingCode": payload.bookingCode,
            "bookingDate": payload.bookingDate,
            "startTime": payload.startTime,
            "endTime": payload.endTime,
            "durationHours": payload.durationHours,
            "pricePerHour": payload.pricePerHour,
            "totalAmount": payload.totalAmount,
            "bookingStatus": payload.bookingStatus,
            "paymentStatus": payload.paymentStatus,
            "createdBy": payload.createdBy
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        let bookings = try parseBookingsResponse(data: data, response: response)
        guard let createdBooking = bookings.first else {
            throw BackendBookingsError.invalidPayload
        }
        return createdBooking
    }

    func updateBookingStatus(
        bookingId: String,
        bookingStatus: String,
        paymentStatus: String
    ) async throws -> BackendBookingRecord {
        guard let url = URL(string: "\(baseURL)/api/bookings/\(bookingId)") else {
            throw BackendBookingsError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "bookingStatus": bookingStatus,
            "paymentStatus": paymentStatus
        ])

        let (data, response) = try await session.data(for: request)
        let bookings = try parseBookingsResponse(data: data, response: response)
        guard let updatedBooking = bookings.first else {
            throw BackendBookingsError.invalidPayload
        }
        return updatedBooking
    }

    func orderStatus(for booking: BackendBookingRecord) -> OrderStatus {
        let paymentValue = booking.paymentStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let bookingValue = booking.bookingStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if paymentValue == "paid" || bookingValue == "fully paid" || bookingValue == "active" || bookingValue == "confirmed" {
            return .success
        }
        if paymentValue == "cancelled" || bookingValue == "cancelled" {
            return .cancelled
        }
        return .pending
    }

    func paymentInfo(from booking: BackendBookingRecord) -> PaymentInfo {
        let status = orderStatus(for: booking)
        return PaymentInfo(
            productImage: iconImage(for: status),
            productName: booking.courtName,
            subtitle: "\(booking.bookingCode) • \(booking.bookingDate) • \(booking.startTime)-\(booking.endTime)",
            price: currencyText(booking.totalAmount),
            paymentMethod: booking.paymentStatus,
            status: status
        )
    }

    private func parseBookingsResponse(data: Data, response: URLResponse) throws -> [BackendBookingRecord] {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendBookingsError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if
                let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let message = object["message"] as? String
            {
                throw BackendBookingsError.server(message)
            }
            throw BackendBookingsError.invalidResponse
        }

        let payload = try JSONSerialization.jsonObject(with: data)
        let items: [[String: Any]]

        if let dictionary = payload as? [String: Any], let dataArray = dictionary["data"] as? [[String: Any]] {
            items = dataArray
        } else if let dictionary = payload as? [String: Any] {
            items = [dictionary]
        } else if let array = payload as? [[String: Any]] {
            items = array
        } else {
            throw BackendBookingsError.invalidPayload
        }

        return items.compactMap(makeBookingRecord(from:))
    }

    private func makeBookingRecord(from item: [String: Any]) -> BackendBookingRecord? {
        let id = (item["id"] as? String) ?? (item["bookingCode"] as? String) ?? UUID().uuidString
        let bookingCode = (item["bookingCode"] as? String) ?? id
        let userId = (item["userId"] as? String) ?? ""
        let courtId = (item["courtId"] as? String) ?? ""
        let courtName = (item["courtName"] as? String) ?? (item["courtId"] as? String) ?? "Sân chưa xác định"
        let bookingDate = (item["bookingDate"] as? String) ?? "--/--/----"
        let startTime = (item["startTime"] as? String) ?? "--:--"
        let endTime = (item["endTime"] as? String) ?? "--:--"
        let bookingStatus = (item["bookingStatus"] as? String) ?? "pending"
        let paymentStatus = (item["paymentStatus"] as? String) ?? "pending"

        let totalAmount: Double = {
            if let value = item["totalAmount"] as? Double { return value }
            if let value = item["totalAmount"] as? Int { return Double(value) }
            if let value = item["totalAmount"] as? String, let parsed = Double(value) { return parsed }
            return 0
        }()

        return BackendBookingRecord(
            id: id,
            bookingCode: bookingCode,
            userId: userId,
            courtId: courtId,
            courtName: courtName,
            bookingDate: bookingDate,
            startTime: startTime,
            endTime: endTime,
            totalAmount: totalAmount,
            bookingStatus: bookingStatus,
            paymentStatus: paymentStatus
        )
    }

    private func currencyText(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "0 đ"
    }

    private func iconImage(for status: OrderStatus) -> UIImage? {
        switch status {
        case .success:
            return UIImage(systemName: "checkmark.seal.fill")
        case .pending:
            return UIImage(systemName: "clock.badge")
        case .cancelled:
            return UIImage(systemName: "xmark.circle.fill")
        }
    }
}

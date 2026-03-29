import Foundation

struct BackendVoucherPreview {
    let voucherId: String?
    let code: String
    let discountType: String?
    let discountValue: Double?
    let discountAmount: Double
    let finalAmount: Double
    let applied: Bool
    let message: String?
}

struct BackendVoucherCard {
    let id: String
    let code: String
    let name: String
    let discountType: String
    let discountValue: Double?
    let status: String
}

enum BackendVouchersError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidPayload
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL voucher backend không hợp lệ."
        case .invalidResponse:
            return "Không nhận được phản hồi hợp lệ từ API voucher."
        case .invalidPayload:
            return "Dữ liệu voucher trả về không đúng định dạng."
        case .server(let message):
            return message
        }
    }
}

final class BackendVouchersService {
    static let shared = BackendVouchersService()

    private let session: URLSession
    private let baseURL = "http://localhost:3000"

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func previewVoucherApplication(
        code: String,
        bookingAmount: Double,
        courtType: String? = nil
    ) async throws -> BackendVoucherPreview {
        guard let url = URL(string: "\(baseURL)/api/vouchers/apply") else {
            throw BackendVouchersError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "code": code,
            "bookingAmount": bookingAmount
        ]
        if let courtType, !courtType.isEmpty {
            body["courtType"] = courtType
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        return try parsePreviewResponse(data: data, response: response)
    }

    func fetchVouchers(status: String? = nil, code: String? = nil) async throws -> [BackendVoucherCard] {
        var components = URLComponents(string: "\(baseURL)/api/vouchers")
        components?.queryItems = [
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "code", value: code)
        ].filter { item in
            guard let value = item.value else { return false }
            return value.isEmpty == false
        }

        guard let url = components?.url else {
            throw BackendVouchersError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        return try parseListResponse(data: data, response: response)
    }

    private func parsePreviewResponse(data: Data, response: URLResponse) throws -> BackendVoucherPreview {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendVouchersError.invalidResponse
        }

        let payload = try JSONSerialization.jsonObject(with: data)
        let object = payload as? [String: Any]

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let message = object?["message"] as? String {
                throw BackendVouchersError.server(message)
            }
            throw BackendVouchersError.invalidResponse
        }

        let dataObject = (object?["data"] as? [String: Any]) ?? object ?? [:]
        let code = (dataObject["code"] as? String) ?? (object?["code"] as? String) ?? ""
        let applied = (dataObject["applied"] as? Bool) ?? (dataObject["isApplicable"] as? Bool) ?? true
        let discountAmount = numericValue(
            from: dataObject["discountAmount"]
        ) ?? numericValue(from: dataObject["discount"]) ?? numericValue(from: dataObject["appliedDiscount"]) ?? 0
        let finalAmount = numericValue(
            from: dataObject["finalAmount"]
        ) ?? numericValue(from: dataObject["finalBookingAmount"]) ?? numericValue(from: dataObject["payableAmount"]) ?? 0

        let resolvedFinalAmount = finalAmount > 0 ? finalAmount : max((numericValue(from: dataObject["bookingAmount"]) ?? 0) - discountAmount, 0)

        guard code.isEmpty == false || discountAmount >= 0 else {
            throw BackendVouchersError.invalidPayload
        }

        return BackendVoucherPreview(
            voucherId: dataObject["voucherId"] as? String ?? dataObject["id"] as? String,
            code: code,
            discountType: dataObject["discountType"] as? String,
            discountValue: numericValue(from: dataObject["discountValue"]),
            discountAmount: discountAmount,
            finalAmount: resolvedFinalAmount,
            applied: applied,
            message: dataObject["message"] as? String ?? object?["message"] as? String
        )
    }

    private func numericValue(from rawValue: Any?) -> Double? {
        if let value = rawValue as? Double { return value }
        if let value = rawValue as? Int { return Double(value) }
        if let value = rawValue as? String { return Double(value) }
        return nil
    }

    private func parseListResponse(data: Data, response: URLResponse) throws -> [BackendVoucherCard] {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendVouchersError.invalidResponse
        }

        let payload = try JSONSerialization.jsonObject(with: data)
        let object = payload as? [String: Any]

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let message = object?["message"] as? String {
                throw BackendVouchersError.server(message)
            }
            throw BackendVouchersError.invalidResponse
        }

        let items: [[String: Any]]
        if let dataArray = object?["data"] as? [[String: Any]] {
            items = dataArray
        } else if let array = payload as? [[String: Any]] {
            items = array
        } else {
            throw BackendVouchersError.invalidPayload
        }

        return items.compactMap { item in
            let id = (item["id"] as? String) ?? UUID().uuidString
            let code = (item["code"] as? String) ?? ""
            let name = (item["name"] as? String) ?? "Voucher ưu đãi"
            let discountType = (item["discountType"] as? String) ?? "fixed"
            let status = (item["status"] as? String) ?? "inactive"

            guard code.isEmpty == false else { return nil }

            return BackendVoucherCard(
                id: id,
                code: code,
                name: name,
                discountType: discountType,
                discountValue: numericValue(from: item["discountValue"]),
                status: status
            )
        }
    }
}

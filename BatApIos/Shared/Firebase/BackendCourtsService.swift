import Foundation

struct BackendCourtCard {
    let id: String
    let name: String
    let type: String
    let status: String
    let pricePerHour: Double
    let priceText: String
}

struct BackendCourtOption {
    let id: String
    let name: String
    let type: String
    let status: String
    let pricePerHour: Double
    let priceText: String
}

enum BackendCourtsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidPayload

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL danh sách sân không hợp lệ."
        case .invalidResponse:
            return "Không nhận được phản hồi hợp lệ từ API sân."
        case .invalidPayload:
            return "Dữ liệu sân trả về không đúng định dạng."
        }
    }
}

final class BackendCourtsService {
    static let shared = BackendCourtsService()

    private let session: URLSession
    private let baseURL = "http://localhost:3000"

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCourts() async throws -> [BackendCourtCard] {
        try await fetchCourtOptions().map {
            BackendCourtCard(
                id: $0.id,
                name: $0.name,
                type: $0.type,
                status: $0.status,
                pricePerHour: $0.pricePerHour,
                priceText: $0.priceText
            )
        }
    }

    func fetchCourtOptions() async throws -> [BackendCourtOption] {
        guard let url = URL(string: "\(baseURL)/api/courts") else {
            throw BackendCourtsError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw BackendCourtsError.invalidResponse
        }

        let payload = try JSONSerialization.jsonObject(with: data)
        let items: [[String: Any]]

        if let dictionary = payload as? [String: Any], let dataArray = dictionary["data"] as? [[String: Any]] {
            items = dataArray
        } else if let array = payload as? [[String: Any]] {
            items = array
        } else {
            throw BackendCourtsError.invalidPayload
        }

        return items.compactMap { item in
            let id = Self.resolveCourtID(from: item)
            guard id.isEmpty == false else { return nil }
            let name = (item["name"] as? String) ?? (item["courtName"] as? String) ?? "Sân chưa đặt tên"
            let type = (item["courtType"] as? String) ?? (item["type"] as? String) ?? "Standard"
            let status = (item["status"] as? String) ?? "Active"

            let priceValue: Double? = {
                if let price = item["pricePerHour"] as? Double { return price }
                if let price = item["price"] as? Double { return price }
                if let price = item["pricePerHour"] as? Int { return Double(price) }
                if let price = item["price"] as? Int { return Double(price) }
                return nil
            }()

            return BackendCourtOption(
                id: id,
                name: name,
                type: type,
                status: status,
                pricePerHour: priceValue ?? 0,
                priceText: Self.currencyText(for: priceValue ?? 0)
            )
        }
    }

    private static func currencyText(for value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0 đ"
    }

    private static func resolveCourtID(from item: [String: Any]) -> String {
        let candidateKeys = [
            "id",
            "courtId",
            "court_id",
            "_id",
            "documentId",
            "docId"
        ]

        for key in candidateKeys {
            if let value = item[key] as? String, value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return value
            }
        }

        return ""
    }
}

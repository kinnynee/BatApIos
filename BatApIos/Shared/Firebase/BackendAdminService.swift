import Foundation

struct BackendAdminOverview {
    let totalUsers: Int
    let totalCourts: Int
    let totalBookings: Int
    let totalPayments: Int
    let totalRevenue: Double
    let bookingStats: [String: Int]
}

struct BackendAdminUser {
    let id: String
    let fullName: String
    let email: String
    let role: String
    let status: String
}

struct BackendAdminCourt {
    let id: String
    let name: String
    let courtType: String
    let status: String
    let pricePerHour: Double
}

struct BackendAdminPayment {
    let id: String
    let bookingId: String
    let userId: String
    let amount: Double
    let paymentStatus: String
    let paymentMethod: String
    let createdAt: String
}

enum BackendAdminError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidPayload
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL admin backend không hợp lệ."
        case .invalidResponse:
            return "Không nhận được phản hồi hợp lệ từ API admin."
        case .invalidPayload:
            return "Dữ liệu admin trả về không đúng định dạng."
        case .server(let message):
            return message
        }
    }
}

final class BackendAdminService {
    static let shared = BackendAdminService()

    private let baseURL = "http://localhost:3000"
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchOverview() async throws -> BackendAdminOverview {
        let object = try await requestObject(path: "/api/admin/overview")
        return BackendAdminOverview(
            totalUsers: Self.intValue(from: object["totalUsers"]),
            totalCourts: Self.intValue(from: object["totalCourts"]),
            totalBookings: Self.intValue(from: object["totalBookings"]),
            totalPayments: Self.intValue(from: object["totalPayments"]),
            totalRevenue: Self.doubleValue(from: object["totalRevenue"]),
            bookingStats: object["bookingStats"] as? [String: Int] ?? [:]
        )
    }

    func fetchUsers(role: String? = nil, status: String? = nil) async throws -> [BackendAdminUser] {
        let items = try await requestArray(path: "/api/admin/users", queryItems: [
            URLQueryItem(name: "role", value: role),
            URLQueryItem(name: "status", value: status)
        ])

        return items.compactMap { item in
            let id = Self.stringValue(from: item["id"]) ?? Self.stringValue(from: item["uid"]) ?? ""
            guard id.isEmpty == false else { return nil }
            return BackendAdminUser(
                id: id,
                fullName: Self.stringValue(from: item["fullName"]) ?? Self.stringValue(from: item["username"]) ?? Self.stringValue(from: item["name"]) ?? id,
                email: Self.stringValue(from: item["email"]) ?? "",
                role: Self.stringValue(from: item["role"]) ?? "user",
                status: Self.stringValue(from: item["status"]) ?? "active"
            )
        }
    }

    func updateUser(userId: String, role: String? = nil, status: String? = nil) async throws -> BackendAdminUser {
        var body: [String: Any] = [:]
        if let role { body["role"] = role }
        if let status { body["status"] = status }
        let item = try await patchObject(path: "/api/admin/users/\(userId)", body: body)
        return BackendAdminUser(
            id: Self.stringValue(from: item["id"]) ?? Self.stringValue(from: item["uid"]) ?? userId,
            fullName: Self.stringValue(from: item["fullName"]) ?? Self.stringValue(from: item["username"]) ?? Self.stringValue(from: item["name"]) ?? userId,
            email: Self.stringValue(from: item["email"]) ?? "",
            role: Self.stringValue(from: item["role"]) ?? "user",
            status: Self.stringValue(from: item["status"]) ?? "active"
        )
    }

    func fetchCourts(status: String? = nil, courtType: String? = nil) async throws -> [BackendAdminCourt] {
        let items = try await requestArray(path: "/api/admin/courts", queryItems: [
            URLQueryItem(name: "status", value: status),
            URLQueryItem(name: "courtType", value: courtType)
        ])

        return items.compactMap { item in
            let id = Self.stringValue(from: item["id"]) ?? Self.stringValue(from: item["courtId"]) ?? Self.stringValue(from: item["court_id"]) ?? ""
            guard id.isEmpty == false else { return nil }
            return BackendAdminCourt(
                id: id,
                name: Self.stringValue(from: item["name"]) ?? Self.stringValue(from: item["courtName"]) ?? "Sân chưa đặt tên",
                courtType: Self.stringValue(from: item["courtType"]) ?? Self.stringValue(from: item["type"]) ?? "single",
                status: Self.stringValue(from: item["status"]) ?? "active",
                pricePerHour: Self.doubleValue(from: item["pricePerHour"] ?? item["price"])
            )
        }
    }

    func createCourt(id: String, name: String, courtType: String, status: String, pricePerHour: Double) async throws -> BackendAdminCourt {
        let item = try await postObject(path: "/api/admin/courts", body: [
            "id": id,
            "name": name,
            "courtType": courtType,
            "status": status,
            "pricePerHour": pricePerHour
        ])

        return BackendAdminCourt(
            id: Self.stringValue(from: item["id"]) ?? id,
            name: Self.stringValue(from: item["name"]) ?? name,
            courtType: Self.stringValue(from: item["courtType"]) ?? courtType,
            status: Self.stringValue(from: item["status"]) ?? status,
            pricePerHour: Self.doubleValue(from: item["pricePerHour"] ?? item["price"])
        )
    }

    func updateCourt(courtId: String, payload: [String: Any]) async throws -> BackendAdminCourt {
        let item = try await patchObject(path: "/api/admin/courts/\(courtId)", body: payload)
        return BackendAdminCourt(
            id: Self.stringValue(from: item["id"]) ?? Self.stringValue(from: item["courtId"]) ?? courtId,
            name: Self.stringValue(from: item["name"]) ?? Self.stringValue(from: item["courtName"]) ?? "Sân chưa đặt tên",
            courtType: Self.stringValue(from: item["courtType"]) ?? Self.stringValue(from: item["type"]) ?? "single",
            status: Self.stringValue(from: item["status"]) ?? "active",
            pricePerHour: Self.doubleValue(from: item["pricePerHour"] ?? item["price"])
        )
    }

    func fetchBookings(
        userId: String? = nil,
        courtId: String? = nil,
        bookingDate: String? = nil,
        bookingStatus: String? = nil
    ) async throws -> [BackendBookingRecord] {
        let items = try await requestArray(path: "/api/admin/bookings", queryItems: [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "courtId", value: courtId),
            URLQueryItem(name: "bookingDate", value: bookingDate),
            URLQueryItem(name: "bookingStatus", value: bookingStatus)
        ])

        return items.compactMap(Self.makeBookingRecord(from:))
    }

    func checkInBooking(bookingId: String, checkedInBy: String, note: String? = nil) async throws -> BackendBookingRecord {
        var body: [String: Any] = ["checkedInBy": checkedInBy]
        if let note, note.isEmpty == false {
            body["checkInNote"] = note
        }
        let item = try await postObject(path: "/api/admin/bookings/\(bookingId)/check-in", body: body)
        guard let booking = Self.makeBookingRecord(from: item) else {
            throw BackendAdminError.invalidPayload
        }
        return booking
    }

    func fetchPayments(
        userId: String? = nil,
        bookingId: String? = nil,
        paymentStatus: String? = nil
    ) async throws -> [BackendAdminPayment] {
        let items = try await requestArray(path: "/api/admin/payments", queryItems: [
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "bookingId", value: bookingId),
            URLQueryItem(name: "paymentStatus", value: paymentStatus)
        ])

        return items.compactMap { item in
            let id = Self.stringValue(from: item["id"]) ?? Self.stringValue(from: item["paymentId"]) ?? ""
            guard id.isEmpty == false else { return nil }
            return BackendAdminPayment(
                id: id,
                bookingId: Self.stringValue(from: item["bookingId"]) ?? "",
                userId: Self.stringValue(from: item["userId"]) ?? "",
                amount: Self.doubleValue(from: item["amount"]),
                paymentStatus: Self.stringValue(from: item["paymentStatus"]) ?? "pending",
                paymentMethod: Self.stringValue(from: item["paymentMethod"]) ?? Self.stringValue(from: item["method"]) ?? "--",
                createdAt: Self.stringValue(from: item["createdAt"]) ?? Self.stringValue(from: item["paidAt"]) ?? ""
            )
        }
    }

    func confirmPayment(paymentId: String, confirmedBy: String) async throws -> BackendAdminPayment {
        let item = try await postObject(path: "/api/admin/payments/\(paymentId)/confirm", body: [
            "confirmedBy": confirmedBy
        ])

        return BackendAdminPayment(
            id: Self.stringValue(from: item["id"]) ?? Self.stringValue(from: item["paymentId"]) ?? paymentId,
            bookingId: Self.stringValue(from: item["bookingId"]) ?? "",
            userId: Self.stringValue(from: item["userId"]) ?? "",
            amount: Self.doubleValue(from: item["amount"]),
            paymentStatus: Self.stringValue(from: item["paymentStatus"]) ?? "paid",
            paymentMethod: Self.stringValue(from: item["paymentMethod"]) ?? Self.stringValue(from: item["method"]) ?? "--",
            createdAt: Self.stringValue(from: item["createdAt"]) ?? Self.stringValue(from: item["paidAt"]) ?? ""
        )
    }

    private func requestArray(path: String, queryItems: [URLQueryItem]) async throws -> [[String: Any]] {
        let payload = try await performRequest(path: path, method: "GET", queryItems: queryItems, body: nil)
        if let array = payload["data"] as? [[String: Any]] {
            return array
        }
        if let array = payload["data"] as? [Any] {
            return array.compactMap { $0 as? [String: Any] }
        }
        throw BackendAdminError.invalidPayload
    }

    private func requestObject(path: String, queryItems: [URLQueryItem] = []) async throws -> [String: Any] {
        let payload = try await performRequest(path: path, method: "GET", queryItems: queryItems, body: nil)
        if let object = payload["data"] as? [String: Any] {
            return object
        }
        throw BackendAdminError.invalidPayload
    }

    private func postObject(path: String, body: [String: Any]) async throws -> [String: Any] {
        let payload = try await performRequest(path: path, method: "POST", queryItems: [], body: body)
        if let object = payload["data"] as? [String: Any] {
            return object
        }
        throw BackendAdminError.invalidPayload
    }

    private func patchObject(path: String, body: [String: Any]) async throws -> [String: Any] {
        let payload = try await performRequest(path: path, method: "PATCH", queryItems: [], body: body)
        if let object = payload["data"] as? [String: Any] {
            return object
        }
        throw BackendAdminError.invalidPayload
    }

    private func performRequest(
        path: String,
        method: String,
        queryItems: [URLQueryItem],
        body: [String: Any]?
    ) async throws -> [String: Any] {
        guard var components = URLComponents(string: "\(baseURL)\(path)") else {
            throw BackendAdminError.invalidURL
        }
        let filteredQueryItems = queryItems.filter { ($0.value?.isEmpty == false) }
        if filteredQueryItems.isEmpty == false {
            components.queryItems = filteredQueryItems
        }
        guard let url = components.url else {
            throw BackendAdminError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendAdminError.invalidResponse
        }

        let rawObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]

        guard (200..<300).contains(httpResponse.statusCode) else {
            if let message = rawObject?["message"] as? String {
                throw BackendAdminError.server(message)
            }
            throw BackendAdminError.invalidResponse
        }

        guard let rawObject else {
            throw BackendAdminError.invalidPayload
        }
        return rawObject
    }

    private static func stringValue(from raw: Any?) -> String? {
        if let value = raw as? String {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        return nil
    }

    private static func intValue(from raw: Any?) -> Int {
        if let value = raw as? Int { return value }
        if let value = raw as? Double { return Int(value) }
        if let value = raw as? String, let parsed = Int(value) { return parsed }
        return 0
    }

    private static func doubleValue(from raw: Any?) -> Double {
        if let value = raw as? Double { return value }
        if let value = raw as? Int { return Double(value) }
        if let value = raw as? String, let parsed = Double(value) { return parsed }
        return 0
    }

    private static func makeBookingRecord(from item: [String: Any]) -> BackendBookingRecord? {
        let id = stringValue(from: item["id"]) ?? stringValue(from: item["bookingId"]) ?? stringValue(from: item["bookingCode"]) ?? ""
        guard id.isEmpty == false else { return nil }

        return BackendBookingRecord(
            id: id,
            bookingCode: stringValue(from: item["bookingCode"]) ?? id,
            userId: stringValue(from: item["userId"]) ?? "",
            courtId: stringValue(from: item["courtId"]) ?? "",
            courtName: stringValue(from: item["courtName"]) ?? stringValue(from: item["courtId"]) ?? "Sân chưa xác định",
            bookingDate: stringValue(from: item["bookingDate"]) ?? "--/--/----",
            startTime: stringValue(from: item["startTime"]) ?? "--:--",
            endTime: stringValue(from: item["endTime"]) ?? "--:--",
            totalAmount: doubleValue(from: item["totalAmount"]),
            bookingStatus: stringValue(from: item["bookingStatus"]) ?? "pending",
            paymentStatus: stringValue(from: item["paymentStatus"]) ?? "pending"
        )
    }
}

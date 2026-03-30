import Foundation

struct BackendLoginProfile: Decodable {
    let fullName: String?
    let email: String?
    let phone: String?
    let avatarUrl: String?
    let role: String?
    let status: String?
}

struct BackendLoginData: Decodable {
    let uid: String
    let email: String
    let idToken: String
    let refreshToken: String
    let expiresIn: String
    let registered: Bool
    let profile: BackendLoginProfile
}

struct BackendLoginResponse: Decodable {
    let success: Bool
    let data: BackendLoginData
}

struct BackendProfileResponse: Decodable {
    let success: Bool
    let data: BackendLoginProfile
}

enum BackendAuthError: LocalizedError {
    case invalidURL
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Base URL backend không hợp lệ."
        case .invalidResponse:
            return "Phản hồi từ backend không hợp lệ."
        case .server(let message):
            return message
        }
    }
}

final class BackendAuthService {
    static let shared = BackendAuthService()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let baseURL = "http://localhost:3000"
    private let sessionUIDKey = "batapp.backend.uid"
    private let sessionEmailKey = "batapp.backend.email"
    private let sessionNameKey = "batapp.backend.fullName"
    private let sessionRoleKey = "batapp.backend.role"
    private let sessionIDTokenKey = "batapp.backend.idToken"
    private let sessionRefreshTokenKey = "batapp.backend.refreshToken"

    private init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func login(email: String, password: String) async throws -> BackendLoginData {
        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
            throw BackendAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode([
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "password": password
        ])

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendAuthError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            let payload: BackendLoginResponse

            do {
                payload = try decoder.decode(BackendLoginResponse.self, from: data)
            } catch {
                let rawResponse = String(data: data, encoding: .utf8) ?? "Không đọc được nội dung phản hồi."
                throw BackendAuthError.server("Không đọc được dữ liệu đăng nhập từ backend. Raw response: \(rawResponse)")
            }

            persistSession(from: payload.data)
            return payload.data
        }

        if let serverMessage = try? decoder.decode(BackendErrorResponse.self, from: data) {
            throw BackendAuthError.server(serverMessage.message)
        }

        throw BackendAuthError.server("Đăng nhập thất bại với mã \(httpResponse.statusCode).")
    }

    func getProfile(uid: String) async throws -> BackendLoginProfile {
        guard
            let encodedUID = uid.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: "\(baseURL)/api/auth/profile/\(encodedUID)")
        else {
            throw BackendAuthError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendAuthError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            do {
                return try decoder.decode(BackendProfileResponse.self, from: data).data
            } catch {
                let rawResponse = String(data: data, encoding: .utf8) ?? "Không đọc được nội dung phản hồi."
                throw BackendAuthError.server("Không đọc được hồ sơ người dùng từ backend. Raw response: \(rawResponse)")
            }
        }

        if let serverMessage = try? decoder.decode(BackendErrorResponse.self, from: data) {
            throw BackendAuthError.server(serverMessage.message)
        }

        throw BackendAuthError.server("Không tải được hồ sơ người dùng với mã \(httpResponse.statusCode).")
    }

    func updateProfile(uid: String, name: String) async throws {
        guard
            let encodedUID = uid.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: "\(baseURL)/api/auth/profile/\(encodedUID)")
        else {
            throw BackendAuthError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(["fullName": name.trimmingCharacters(in: .whitespacesAndNewlines)])

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendAuthError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            UserDefaults.standard.set(name, forKey: sessionNameKey)
            return
        }

        if let serverMessage = try? decoder.decode(BackendErrorResponse.self, from: data) {
            throw BackendAuthError.server(serverMessage.message)
        }

        throw BackendAuthError.server("Không thể cập nhật hồ sơ với mã \(httpResponse.statusCode).")
    }

    func userRole(from roleText: String) -> UserRole {
        switch roleText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "admin":
            return .admin
        case "staff":
            return .staff
        default:
            return .user
        }
    }

    func restorePersistedUser() -> User? {
        guard
            let uid = UserDefaults.standard.string(forKey: sessionUIDKey),
            let email = UserDefaults.standard.string(forKey: sessionEmailKey)
        else {
            return nil
        }

        let fullName = UserDefaults.standard.string(forKey: sessionNameKey)
        let roleText = UserDefaults.standard.string(forKey: sessionRoleKey) ?? "user"

        return User(
            id: uid,
            email: email,
            username: fullName?.isEmpty == false ? fullName! : email,
            password: "",
            role: userRole(from: roleText),
            walletBalance: 0,
            createdAt: nil,
            updatedAt: Date()
        )
    }

    func clearSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: sessionUIDKey)
        defaults.removeObject(forKey: sessionEmailKey)
        defaults.removeObject(forKey: sessionNameKey)
        defaults.removeObject(forKey: sessionRoleKey)
        defaults.removeObject(forKey: sessionIDTokenKey)
        defaults.removeObject(forKey: sessionRefreshTokenKey)
    }

    private func persistSession(from loginData: BackendLoginData) {
        let defaults = UserDefaults.standard
        defaults.set(loginData.uid, forKey: sessionUIDKey)
        defaults.set(loginData.email, forKey: sessionEmailKey)
        defaults.set(loginData.profile.fullName, forKey: sessionNameKey)
        defaults.set(loginData.profile.role ?? "user", forKey: sessionRoleKey)
        defaults.set(loginData.idToken, forKey: sessionIDTokenKey)
        defaults.set(loginData.refreshToken, forKey: sessionRefreshTokenKey)
    }
}

private struct BackendErrorResponse: Decodable {
    let message: String
}

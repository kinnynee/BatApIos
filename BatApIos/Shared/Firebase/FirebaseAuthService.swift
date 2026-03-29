import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthService {
    static let shared = FirebaseAuthService()

    private let auth = Auth.auth()
    private let database = Firestore.firestore()

    private init() {}

    func login(email: String, password: String) async throws -> User {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let result = try await auth.signIn(withEmail: normalizedEmail, password: password)
        return try await userProfile(for: result.user, fallbackName: result.user.displayName)
    }

    func register(name: String, email: String, password: String) async throws -> User {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = try await auth.createUser(withEmail: normalizedEmail, password: password)

        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = trimmedName
        try await changeRequest.commitChanges()

        let user = User(
            id: result.user.uid,
            email: normalizedEmail,
            username: trimmedName,
            password: "",
            role: .user,
            walletBalance: 0,
            createdAt: Date(),
            updatedAt: Date()
        )

        try await saveUserProfile(user)
        return user
    }

    func sendPasswordReset(email: String) async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        try await auth.sendPasswordReset(withEmail: normalizedEmail)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let currentUser = auth.currentUser, let email = currentUser.email else {
            throw AppLogicError.noActiveSession
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        try await currentUser.reauthenticate(with: credential)
        try await currentUser.updatePassword(to: newPassword)
    }

    func signOut() throws {
        try auth.signOut()
    }

    private func userProfile(for firebaseUser: FirebaseAuth.User, fallbackName: String?) async throws -> User {
        let snapshot = try await database.collection("users").document(firebaseUser.uid).getDocument()
        let data = snapshot.data()
        let username = (data?["username"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = firebaseUser.email ?? (data?["email"] as? String) ?? ""
        let roleRawValue = data?["role"] as? String
        let role = roleRawValue.flatMap(UserRole.init(rawValue:)) ?? .user
        let walletBalance = data?["wallet_balance"] as? Double ?? 0
        let createdAt = (data?["created_at"] as? Timestamp)?.dateValue()
        let updatedAt = (data?["updated_at"] as? Timestamp)?.dateValue()

        let user = User(
            id: firebaseUser.uid,
            email: email,
            username: (username?.isEmpty == false ? username : fallbackName) ?? email,
            password: "",
            role: role,
            walletBalance: walletBalance,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        if snapshot.exists == false {
            try await saveUserProfile(user)
        }

        return user
    }

    private func saveUserProfile(_ user: User) async throws {
        guard let id = user.id else { return }

        let payload: [String: Any] = [
            "id": id,
            "email": user.email,
            "username": user.username,
            "role": user.role.rawValue,
            "wallet_balance": user.walletBalance,
            "created_at": Timestamp(date: user.createdAt ?? Date()),
            "updated_at": Timestamp(date: Date())
        ]

        try await database.collection("users").document(id).setData(payload, merge: true)
    }
}

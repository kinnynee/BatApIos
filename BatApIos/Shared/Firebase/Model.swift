//
//  File.swift
//  BatApIos
//
//  Created by Trần Kiên on 20/3/26.
//
import Foundation

enum UserRole: String, Codable {
    case user = "User"
    case admin = "Admin"
    case staff = "Staff"
}

enum CourtType: String, Codable {
    case double = "Double"
    case vip = "Vip"
    case single = "Single"
}

enum CourtStatus: String, Codable {
    case active = "Active"
    case maintenance = "Maintenance"
}

enum BookingStatus: String, Codable {
    case pending = "Pending"
    case partiallyPaid = "Partially Paid"
    case fullyPaid = "Fully Paid"
    case active = "Active"
    case cancelled = "Cancelled"
}

// MARK: - 1. Bảng Users
struct User: Codable {
    var id: String?
    var email: String
    var username: String
    var password: String
    var role: UserRole = .user
    var walletBalance: Double = 0.0
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, email, username, password, role
        case walletBalance = "wallet_balance"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - 2. Bảng Locations
struct Location: Codable {
    var id: String?
    var name: String
    var address: String
}

// MARK: - 3. Bảng Courts
struct Court: Codable {
    var id: String?
    var name: String
    var type: CourtType = .double
    var locationId: String
    var pricePerHour: Double
    var status: CourtStatus = .active

    enum CodingKeys: String, CodingKey {
        case id, name, type, status
        case locationId = "location_id"
        case pricePerHour = "price_per_hour"
    }
}

// MARK: - 4. Bảng Bookings
struct Booking: Codable {
    var id: String?
    var userId: String
    var courtId: String
    var bookingDate: Date
    var startTime: Date
    var endTime: Date
    var status: BookingStatus = .pending
    var totalPrice: Double
    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, status
        case userId = "user_id"
        case courtId = "court_id"
        case bookingDate = "booking_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case totalPrice = "total_price"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

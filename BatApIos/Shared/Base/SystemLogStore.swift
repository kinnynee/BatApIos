import Foundation

struct SystemLogEntry {
    let id: String
    let title: String
    let message: String
    let createdAt: Date
    let source: String
}

final class SystemLogStore {
    static let shared = SystemLogStore()

    private var entries: [SystemLogEntry] = [
        SystemLogEntry(
            id: UUID().uuidString,
            title: "Khởi tạo hệ thống",
            message: "Nhật ký hệ thống đã sẵn sàng theo dõi các thao tác backend trong phiên hiện tại.",
            createdAt: Date(),
            source: "system"
        )
    ]

    private let queue = DispatchQueue(label: "batap.system-log-store", qos: .userInitiated)

    private init() {}

    func append(title: String, message: String, source: String) {
        let entry = SystemLogEntry(
            id: UUID().uuidString,
            title: title,
            message: message,
            createdAt: Date(),
            source: source
        )

        queue.sync {
            entries.insert(entry, at: 0)
            if entries.count > 100 {
                entries = Array(entries.prefix(100))
            }
        }
    }

    func allEntries() -> [SystemLogEntry] {
        queue.sync { entries.sorted { $0.createdAt > $1.createdAt } }
    }
}

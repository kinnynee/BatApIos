import UIKit

final class MyBookingsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateLabel = UILabel()
    private let store = AppMockStore.shared
    private let authService = BackendAuthService.shared
    private let bookingsService = BackendBookingsService.shared
    private var bookings: [BackendBookingRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lịch đặt của tôi"
        view.backgroundColor = .systemBackground
        configureTableView()
        configureEmptyState()
        loadBookings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBookings()
    }
}

private extension MyBookingsViewController {
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "bookingCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 92
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureEmptyState() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "Bạn chưa có lịch đặt nào."
        emptyStateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    func loadBookings() {
        Task { [weak self] in
            guard let self else { return }

            let userId = authService.restorePersistedUser()?.id ?? store.currentUser?.id
            guard let userId, userId.isEmpty == false else {
                await MainActor.run {
                    self.bookings = []
                    self.emptyStateLabel.isHidden = false
                    self.tableView.isHidden = true
                    self.tableView.reloadData()
                }
                return
            }

            do {
                let fetchedBookings = try await bookingsService.fetchBookings(userId: userId)
                await MainActor.run {
                    self.bookings = fetchedBookings.sorted {
                        "\($0.bookingDate) \($0.startTime)" > "\($1.bookingDate) \($1.startTime)"
                    }
                    self.emptyStateLabel.isHidden = !self.bookings.isEmpty
                    self.tableView.isHidden = self.bookings.isEmpty
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.bookings = []
                    self.emptyStateLabel.isHidden = false
                    self.tableView.isHidden = true
                    self.tableView.reloadData()
                    self.showAlert(title: "Không tải được booking", message: error.localizedDescription)
                }
            }
        }
    }

    func statusText(for booking: BackendBookingRecord) -> String {
        switch bookingsService.orderStatus(for: booking) {
        case .success:
            return normalizedStatusText(booking.bookingStatus, fallback: "Đã thanh toán")
        case .pending:
            return normalizedStatusText(booking.bookingStatus, fallback: "Chờ thanh toán")
        case .cancelled:
            return "Đã hủy"
        }
    }

    func statusColor(for booking: BackendBookingRecord) -> UIColor {
        switch bookingsService.orderStatus(for: booking) {
        case .success:
            return booking.bookingStatus.caseInsensitiveCompare("active") == .orderedSame ? .systemBlue : .systemGreen
        case .pending:
            return .systemOrange
        case .cancelled:
            return .systemRed
        }
    }

    func normalizedStatusText(_ value: String, fallback: String) -> String {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "active":
            return "Đang diễn ra"
        case "fully paid", "confirmed":
            return "Đã thanh toán"
        case "pending":
            return "Chờ thanh toán"
        case "cancelled":
            return "Đã hủy"
        default:
            return fallback
        }
    }
}

extension MyBookingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath)
        let booking = bookings[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = booking.courtName
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)

        content.secondaryText = "\(booking.bookingDate) • \(booking.startTime) - \(booking.endTime)\n\(statusText(for: booking)) • #\(booking.bookingCode)"
        content.secondaryTextProperties.numberOfLines = 2
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content

        let statusBadge = UILabel()
        statusBadge.text = "  \(statusText(for: booking))  "
        statusBadge.font = .systemFont(ofSize: 11, weight: .bold)
        statusBadge.textColor = statusColor(for: booking)
        statusBadge.backgroundColor = statusColor(for: booking).withAlphaComponent(0.12)
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true
        statusBadge.sizeToFit()
        cell.accessoryView = statusBadge
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailViewController = BookingDetailViewController()
        detailViewController.booking = bookings[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

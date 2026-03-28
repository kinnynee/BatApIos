import UIKit

final class MyBookingsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyStateLabel = UILabel()
    private let store = AppStore.shared
    private var bookings: [BookingRecord] = []

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
        bookings = store.myBookings()
        emptyStateLabel.isHidden = !bookings.isEmpty
        tableView.isHidden = bookings.isEmpty
        tableView.reloadData()
    }

    func statusText(for status: BookingStatus) -> String {
        switch status {
        case .pending:
            return "Chờ thanh toán"
        case .partiallyPaid:
            return "Đã cọc"
        case .fullyPaid:
            return "Đã thanh toán"
        case .active:
            return "Đang diễn ra"
        case .cancelled:
            return "Đã hủy"
        }
    }

    func statusColor(for status: BookingStatus) -> UIColor {
        switch status {
        case .pending:
            return .systemOrange
        case .partiallyPaid:
            return .systemTeal
        case .fullyPaid:
            return .systemGreen
        case .active:
            return .systemBlue
        case .cancelled:
            return .systemRed
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

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateFormatter.dateFormat = "dd/MM/yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "vi_VN")
        timeFormatter.dateFormat = "HH:mm"

        content.secondaryText = "\(dateFormatter.string(from: booking.bookingDate)) • \(timeFormatter.string(from: booking.startTime)) - \(timeFormatter.string(from: booking.endTime))\n\(statusText(for: booking.status)) • #\(booking.id)"
        content.secondaryTextProperties.numberOfLines = 2
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content

        let statusBadge = UILabel()
        statusBadge.text = "  \(statusText(for: booking.status))  "
        statusBadge.font = .systemFont(ofSize: 11, weight: .bold)
        statusBadge.textColor = statusColor(for: booking.status)
        statusBadge.backgroundColor = statusColor(for: booking.status).withAlphaComponent(0.12)
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

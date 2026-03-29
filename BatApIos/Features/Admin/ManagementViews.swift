import Foundation
import UIKit

private extension UIViewController {
    func configureAdminManagementNavigation(title: String) {
        self.title = title
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleAdminBackTap)
        )
        navigationItem.leftBarButtonItem?.tintColor = .label
    }

    @objc func handleAdminBackTap() {
        handleBackNavigation()
    }
}

final class BookingManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let adminService = BackendAdminService.shared
    private let authService = BackendAuthService.shared
    private let bookingsService = BackendBookingsService.shared
    private let courtsService = BackendCourtsService.shared
    private let systemLogStore = SystemLogStore.shared
    private var bookings: [BackendBookingRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminManagementNavigation(title: "Quản lý đặt sân")
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookingMgmtCell.self, forCellReuseIdentifier: "bookingCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let bookings = try await adminService.fetchBookings()
                await MainActor.run {
                    self.bookings = bookings.sorted {
                        "\($0.bookingDate) \($0.startTime)" > "\($1.bookingDate) \($1.startTime)"
                    }
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không tải được booking", message: error.localizedDescription)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath) as? BookingMgmtCell else {
            return UITableViewCell()
        }
        cell.configure(with: bookings[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let booking = bookings[indexPath.row]

        let alert = UIAlertController(title: booking.bookingCode, message: "Chọn thao tác cho booking", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Check-in khách", style: .default, handler: { [weak self] _ in
            self?.checkIn(booking: booking)
        }))
        alert.addAction(UIAlertAction(title: "Hủy booking", style: .destructive, handler: { [weak self] _ in
            self?.cancelBooking(booking)
        }))
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView.cellForRow(at: indexPath)
            popover.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? .zero
        }

        present(alert, animated: true)
    }

    private func checkIn(booking: BackendBookingRecord) {
        let normalizedStatus = booking.bookingStatus.lowercased()
        if normalizedStatus == "cancelled" {
            showAlert(title: "Không thể check-in", message: "Booking này đã bị hủy.")
            return
        }

        if normalizedStatus == "checked_in" || normalizedStatus == "active" {
            showAlert(title: "Đã check-in", message: "Booking này đã được check-in trước đó.")
            return
        }

        guard let adminId = authService.restorePersistedUser()?.id, !adminId.isEmpty else {
            showAlert(title: "Thiếu phiên", message: "Không tìm thấy admin hiện tại.")
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let preparedBooking = try await self.prepareBookingForCheckIn(booking)
                _ = try await adminService.checkInBooking(bookingId: preparedBooking.id, checkedInBy: adminId)
                await MainActor.run {
                    self.systemLogStore.append(
                        title: "Admin check-in",
                        message: "Admin \(adminId) đã check-in booking \(booking.bookingCode).",
                        source: "admin"
                    )
                    self.loadData()
                    self.showAlert(title: "Thành công", message: "Đã check-in booking \(booking.bookingCode).")
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể check-in", message: error.localizedDescription)
                }
            }
        }
    }

    private func cancelBooking(_ booking: BackendBookingRecord) {
        if booking.bookingStatus.lowercased() == "cancelled" {
            showAlert(title: "Đã hủy", message: "Booking này đã ở trạng thái hủy.")
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await bookingsService.cancelBooking(bookingId: booking.id)
                await MainActor.run {
                    self.systemLogStore.append(
                        title: "Admin hủy booking",
                        message: "Admin đã hủy booking \(booking.bookingCode) từ màn quản lý đặt sân.",
                        source: "admin"
                    )
                    self.loadData()
                    self.showAlert(title: "Thành công", message: "Đã hủy booking \(booking.bookingCode).")
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể hủy", message: error.localizedDescription)
                }
            }
        }
    }

    private func prepareBookingForCheckIn(_ booking: BackendBookingRecord) async throws -> BackendBookingRecord {
        let courts = try await courtsService.fetchCourtOptions()
        if courts.contains(where: { $0.id.caseInsensitiveCompare(booking.courtId) == .orderedSame }) {
            return booking
        }

        guard let resolvedCourt = resolveCourt(for: booking, from: courts) else {
            throw NSError(
                domain: "BookingManagement",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Booking này đang trỏ tới sân không tồn tại trên backend. Hãy cập nhật lại courtId trước khi check-in."]
            )
        }

        return try await bookingsService.updateBooking(
            bookingId: booking.id,
            payload: [
                "courtId": resolvedCourt.id,
                "courtName": resolvedCourt.name
            ]
        )
    }

    private func resolveCourt(for booking: BackendBookingRecord, from courts: [BackendCourtOption]) -> BackendCourtOption? {
        let candidates = [booking.courtId, booking.courtName]
            .map(normalizedCourtToken(_:))
            .filter { !$0.isEmpty }

        if let directMatch = courts.first(where: { court in
            let courtTokens = [court.id, court.name, court.type].map(normalizedCourtToken(_:))
            return candidates.contains(where: { candidate in
                courtTokens.contains(candidate)
            })
        }) {
            return directMatch
        }

        if candidates.contains(where: { $0.contains("vip") }) {
            return courts.first(where: { normalizedCourtToken($0.id).contains("vip") || normalizedCourtToken($0.name).contains("vip") || normalizedCourtToken($0.type).contains("vip") })
        }

        if candidates.contains(where: { $0.contains("standard") || $0.contains("thuong") || $0.contains("bth") }) {
            return courts.first(where: {
                let id = normalizedCourtToken($0.id)
                let name = normalizedCourtToken($0.name)
                let type = normalizedCourtToken($0.type)
                return id.contains("thuong") || id.contains("bth") || name.contains("thuong") || type.contains("standard") || type.contains("single")
            })
        }

        return nil
    }

    private func normalizedCourtToken(_ raw: String) -> String {
        raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "vi_VN"))
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}

final class BookingMgmtCell: UITableViewCell {
    private let codeLabel = UILabel()
    private let infoLabel = UILabel()
    private let statusTag = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        codeLabel.font = .boldSystemFont(ofSize: 16)
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .darkGray
        infoLabel.numberOfLines = 3

        statusTag.font = .systemFont(ofSize: 12, weight: .bold)
        statusTag.textColor = .white
        statusTag.layer.cornerRadius = 6
        statusTag.clipsToBounds = true
        statusTag.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [codeLabel, infoLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        statusTag.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusTag)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: statusTag.leadingAnchor, constant: -16),

            statusTag.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusTag.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusTag.widthAnchor.constraint(equalToConstant: 96),
            statusTag.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(with booking: BackendBookingRecord) {
        codeLabel.text = booking.bookingCode
        infoLabel.text = "\(booking.courtName)\n\(booking.bookingDate) • \(booking.startTime)-\(booking.endTime)\nThanh toán: \(booking.paymentStatus)"
        statusTag.text = booking.bookingStatus.uppercased()
        switch booking.bookingStatus.lowercased() {
        case "fully paid", "paid":
            statusTag.backgroundColor = .systemGreen
        case "pending":
            statusTag.backgroundColor = .systemOrange
        case "checked_in", "active":
            statusTag.backgroundColor = .systemBlue
        case "cancelled":
            statusTag.backgroundColor = .systemRed
        default:
            statusTag.backgroundColor = .systemGray
        }
    }
}

final class StaffManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let adminService = BackendAdminService.shared
    private var users: [BackendAdminUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminManagementNavigation(title: "Quản lý người dùng")
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let users = try await adminService.fetchUsers()
                await MainActor.run {
                    self.users = users.sorted { $0.fullName.localizedCaseInsensitiveCompare($1.fullName) == .orderedAscending }
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không tải được người dùng", message: error.localizedDescription)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "userCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)

        let user = users[indexPath.row]
        cell.textLabel?.text = user.fullName
        cell.detailTextLabel?.text = "\(user.email) • \(user.role) • \(user.status)"
        cell.imageView?.image = UIImage(systemName: "person.circle.fill")
        cell.imageView?.tintColor = user.role.lowercased() == "admin" ? .systemRed : (user.role.lowercased() == "staff" ? .systemOrange : .systemBlue)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]

        let alert = UIAlertController(title: user.fullName, message: "Cập nhật role hoặc trạng thái", preferredStyle: .actionSheet)
        let roles = ["user", "staff", "admin"]
        for roleValue in roles {
            alert.addAction(UIAlertAction(title: "Role: \(roleValue)", style: .default, handler: { [weak self] _ in
                self?.updateUser(user, role: roleValue, status: nil)
            }))
        }
        let statuses = ["active", "inactive", "blocked"]
        for statusValue in statuses {
            alert.addAction(UIAlertAction(title: "Status: \(statusValue)", style: .default, handler: { [weak self] _ in
                self?.updateUser(user, role: nil, status: statusValue)
            }))
        }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView.cellForRow(at: indexPath)
            popover.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? .zero
        }

        present(alert, animated: true)
    }

    private func updateUser(_ user: BackendAdminUser, role: String?, status: String?) {
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await adminService.updateUser(userId: user.id, role: role, status: status)
                await MainActor.run {
                    self.loadData()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể cập nhật user", message: error.localizedDescription)
                }
            }
        }
    }
}

final class PaymentManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let adminService = BackendAdminService.shared
    private let authService = BackendAuthService.shared
    private let systemLogStore = SystemLogStore.shared
    private var payments: [BackendAdminPayment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminManagementNavigation(title: "Quản lý thanh toán")
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let payments = try await adminService.fetchPayments()
                await MainActor.run {
                    self.payments = payments.sorted { $0.createdAt > $1.createdAt }
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không tải được thanh toán", message: error.localizedDescription)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        payments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "paymentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        let payment = payments[indexPath.row]
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        let amountText = formatter.string(from: NSNumber(value: payment.amount)) ?? "0 đ"

        cell.textLabel?.text = payment.id
        cell.detailTextLabel?.text = "\(payment.bookingId) • \(amountText) • \(payment.paymentStatus)"
        cell.imageView?.image = UIImage(systemName: payment.paymentStatus.lowercased() == "paid" ? "checkmark.circle.fill" : "creditcard.fill")
        cell.imageView?.tintColor = payment.paymentStatus.lowercased() == "paid" ? .systemGreen : .systemOrange
        cell.accessoryType = payment.paymentStatus.lowercased() == "paid" ? .none : .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let payment = payments[indexPath.row]
        guard payment.paymentStatus.lowercased() != "paid" else { return }
        confirm(payment: payment)
    }

    private func confirm(payment: BackendAdminPayment) {
        guard let adminId = authService.restorePersistedUser()?.id, !adminId.isEmpty else {
            showAlert(title: "Thiếu phiên", message: "Không tìm thấy admin hiện tại.")
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await adminService.confirmPayment(paymentId: payment.id, confirmedBy: adminId)
                await MainActor.run {
                    self.systemLogStore.append(
                        title: "Admin xác nhận thanh toán",
                        message: "Admin \(adminId) đã xác nhận thanh toán \(payment.id) cho booking \(payment.bookingId).",
                        source: "admin"
                    )
                    self.loadData()
                    self.showAlert(title: "Đã xác nhận", message: "Thanh toán \(payment.id) đã được xác nhận.")
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể xác nhận", message: error.localizedDescription)
                }
            }
        }
    }
}

final class MaintenanceViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminManagementNavigation(title: "Lịch sử hệ thống")
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Backend admin hiện chưa có route system logs riêng. Màn này sẽ nối tiếp khi backend bổ sung endpoint log."
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 24)
        ])
    }
}

final class CourtManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let adminService = BackendAdminService.shared
    private var courts: [BackendAdminCourt] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAdminManagementNavigation(title: "Quản lý sân")
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCourtTapped)
        )

        setupTableView()
        loadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let courts = try await adminService.fetchCourts()
                await MainActor.run {
                    self.courts = courts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không tải được sân", message: error.localizedDescription)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        courts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "courtCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)

        let court = courts[indexPath.row]
        cell.textLabel?.text = court.name
        cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        cell.detailTextLabel?.text = "\(court.courtType) • \(Int(court.pricePerHour)) đ/giờ • \(court.status)"
        cell.imageView?.image = UIImage(systemName: "figure.badminton")
        cell.imageView?.tintColor = court.status.lowercased() == "active" ? .systemGreen : .systemRed
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentCourtForm(for: courts[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let court = courts[indexPath.row]
        let toggleTitle = court.status.lowercased() == "active" ? "Bảo trì" : "Kích hoạt"
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.toggleStatus(for: court)
            completion(true)
        }
        toggleAction.backgroundColor = court.status.lowercased() == "active" ? .systemOrange : .systemGreen

        let editAction = UIContextualAction(style: .normal, title: "Sửa") { [weak self] _, _, completion in
            self?.presentCourtForm(for: court)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [toggleAction, editAction])
    }

    @objc private func addCourtTapped() {
        presentCourtForm(for: nil)
    }

    private func toggleStatus(for court: BackendAdminCourt) {
        let newStatus = court.status.lowercased() == "active" ? "maintenance" : "active"
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await adminService.updateCourt(courtId: court.id, payload: ["status": newStatus])
                await MainActor.run { self.loadData() }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể cập nhật sân", message: error.localizedDescription)
                }
            }
        }
    }

    private func presentCourtForm(for court: BackendAdminCourt?) {
        let isEditing = court != nil
        let alert = UIAlertController(
            title: isEditing ? "Sửa sân" : "Thêm sân",
            message: "Nhập tên, loại, giá và trạng thái",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Tên sân"
            textField.text = court?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Loại: single / double / vip"
            textField.autocapitalizationType = .none
            textField.text = court?.courtType.lowercased()
        }
        alert.addTextField { textField in
            textField.placeholder = "Giá theo giờ"
            textField.keyboardType = .numberPad
            if let price = court?.pricePerHour {
                textField.text = String(Int(price))
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "Trạng thái: active / maintenance"
            textField.autocapitalizationType = .none
            textField.text = court?.status.lowercased()
        }

        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Lưu" : "Thêm", style: .default, handler: { [weak self, weak alert] _ in
            guard let self, let alert else { return }
            self.submitCourtForm(alert: alert, editingCourt: court)
        }))

        present(alert, animated: true)
    }

    private func submitCourtForm(alert: UIAlertController, editingCourt: BackendAdminCourt?) {
        let values = alert.textFields?.map { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" } ?? []
        guard values.count == 4 else { return }

        let name = values[0]
        let typeText = values[1].lowercased()
        let priceText = values[2]
        let statusText = values[3].lowercased()

        guard
            name.isEmpty == false,
            let price = Double(priceText),
            price >= 0,
            ["single", "double", "vip"].contains(typeText),
            ["active", "maintenance"].contains(statusText)
        else {
            showAlert(title: "Dữ liệu không hợp lệ", message: "Vui lòng nhập đúng loại sân, trạng thái và giá hợp lệ.")
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                if let editingCourt {
                    _ = try await adminService.updateCourt(courtId: editingCourt.id, payload: [
                        "name": name,
                        "courtType": typeText,
                        "pricePerHour": price,
                        "status": statusText
                    ])
                } else {
                    let generatedId = "court_\(Int(Date().timeIntervalSince1970))"
                    _ = try await adminService.createCourt(id: generatedId, name: name, courtType: typeText, status: statusText, pricePerHour: price)
                }

                await MainActor.run { self.loadData() }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể lưu sân", message: error.localizedDescription)
                }
            }
        }
    }
}

import UIKit
import Foundation

// MARK: - Booking Management

class BookingManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var bookings: [BookingRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quản lý đặt sân"
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadData()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookingMgmtCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        bookings = AppMockStore.shared.getAllBookings()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookingMgmtCell else {
            return UITableViewCell()
        }
        let booking = bookings[indexPath.row]
        cell.configure(with: booking)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let booking = bookings[indexPath.row]
        showStatusPicker(for: booking)
    }
    
    private func showStatusPicker(for booking: BookingRecord) {
        let alert = UIAlertController(title: "Cập nhật trạng thái", message: "Mã: \(booking.id)", preferredStyle: .actionSheet)
        
        let statusOptions: [BookingStatus] = [.pending, .fullyPaid, .active, .cancelled]
        for status in statusOptions {
            alert.addAction(UIAlertAction(title: status.rawValue, style: .default, handler: { [weak self] _ in
                AppMockStore.shared.updateBookingStatus(id: booking.id, status: status)
                self?.loadData()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
}

class BookingMgmtCell: UITableViewCell {
    private let codeLbl = UILabel()
    private let infoLbl = UILabel()
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
        codeLbl.font = .boldSystemFont(ofSize: 16)
        infoLbl.font = .systemFont(ofSize: 14)
        infoLbl.textColor = .darkGray
        infoLbl.numberOfLines = 2
        
        statusTag.font = .systemFont(ofSize: 12, weight: .bold)
        statusTag.textColor = .white
        statusTag.layer.cornerRadius = 6
        statusTag.clipsToBounds = true
        statusTag.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [codeLbl, infoLbl])
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
            statusTag.widthAnchor.constraint(equalToConstant: 90),
            statusTag.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with booking: BookingRecord) {
        codeLbl.text = booking.id
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy HH:mm"
        infoLbl.text = "\(booking.courtName)\n\(df.string(from: booking.startTime)) - \(df.string(from: booking.endTime))"
        
        statusTag.text = booking.status.rawValue.uppercased()
        switch booking.status {
        case .fullyPaid: statusTag.backgroundColor = .systemGreen
        case .pending: statusTag.backgroundColor = .systemOrange
        case .cancelled: statusTag.backgroundColor = .systemRed
        case .active: statusTag.backgroundColor = .systemBlue
        default: statusTag.backgroundColor = .systemGray
        }
    }
}

// MARK: - Staff Management

class StaffManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quản lý nhân sự"
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadData()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        // No registration needed for style-dependent cells if we instantiate manually, or we can use a subclass.
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadData() {
        users = AppMockStore.shared.getAllUsers()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "staffCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = "\(user.email) • \(user.role.rawValue)"
        cell.imageView?.image = UIImage(systemName: "person.circle.fill")
        
        switch user.role {
        case .admin: cell.imageView?.tintColor = .systemRed
        case .staff: cell.imageView?.tintColor = .systemOrange
        case .user: cell.imageView?.tintColor = .systemBlue
        }
        
        return cell
    }
}

// MARK: - Maintenance View Controller

class MaintenanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var logs: [AppNotificationItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lịch sử hệ thống"
        view.backgroundColor = .systemBackground
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
        logs = AppMockStore.shared.getSystemLogs()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "logCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        let log = logs[indexPath.row]
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm dd/MM"
        
        cell.textLabel?.text = log.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14)
        cell.detailTextLabel?.text = "[\(df.string(from: log.createdAt))] \(log.message)"
        cell.detailTextLabel?.textColor = .systemGray
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
}

// MARK: - Court Management View Controller

class CourtManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var courts: [Court] = []
    private let store = AppMockStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quản lý sân"
        view.backgroundColor = .systemBackground
        
        // Custom Back button
        let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backTapped))
        backBtn.tintColor = .black
        navigationItem.leftBarButtonItem = backBtn
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCourtTapped)
        )
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupTableView()
        loadData()
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
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
        courts = store.getAllCourts().sorted { lhs, rhs in
            (lhs.id ?? lhs.name) < (rhs.id ?? rhs.name)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "courtCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        
        let court = courts[indexPath.row]
        cell.textLabel?.text = court.name
        cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        
        let price = Int(court.pricePerHour)
        let statusVN = court.status == .active ? "Đang hoạt động" : "Bảo trì"
        cell.detailTextLabel?.text = "\(court.type.rawValue) • \(price) đ/giờ • \(statusVN)"
        
        cell.imageView?.image = UIImage(systemName: "figure.badminton")
        cell.imageView?.tintColor = court.status == .active ? .systemGreen : .systemRed
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let court = courts[indexPath.row]

        let alert = UIAlertController(title: court.name, message: "Chọn thao tác quản lý sân", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Chỉnh sửa", style: .default, handler: { [weak self] _ in
            self?.presentCourtForm(for: court)
        }))
        alert.addAction(UIAlertAction(title: court.status == .active ? "Chuyển sang bảo trì" : "Chuyển sang hoạt động", style: .default, handler: { [weak self] _ in
            self?.toggleStatus(for: court)
        }))
        alert.addAction(UIAlertAction(title: "Xóa sân", style: .destructive, handler: { [weak self] _ in
            self?.confirmDelete(court: court)
        }))
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = tableView.cellForRow(at: indexPath)
            popover.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? .zero
        }

        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let court = courts[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            self?.confirmDelete(court: court)
            completion(true)
        }

        let editAction = UIContextualAction(style: .normal, title: "Sửa") { [weak self] _, _, completion in
            self?.presentCourtForm(for: court)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    @objc private func addCourtTapped() {
        presentCourtForm(for: nil)
    }

    private func toggleStatus(for court: Court) {
        guard let id = court.id else { return }

        let newStatus: CourtStatus = court.status == .active ? .maintenance : .active
        store.updateCourtStatus(id: id, status: newStatus)
        loadData()
    }

    private func confirmDelete(court: Court) {
        guard let id = court.id else { return }

        let alert = UIAlertController(
            title: "Xóa sân",
            message: "Bạn có chắc muốn xóa \(court.name)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive, handler: { [weak self] _ in
            self?.store.deleteCourt(id: id)
            self?.loadData()
        }))
        present(alert, animated: true)
    }

    private func presentCourtForm(for court: Court?) {
        let isEditing = court != nil
        let alert = UIAlertController(
            title: isEditing ? "Sửa sân" : "Thêm sân",
            message: "Nhập tên, loại, mã cơ sở, giá và trạng thái",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Tên sân"
            textField.text = court?.name
        }
        alert.addTextField { textField in
            textField.placeholder = "Loại: single / double / vip"
            textField.autocapitalizationType = .none
            textField.text = court?.type.rawValue.lowercased()
        }
        alert.addTextField { textField in
            textField.placeholder = "Mã cơ sở, ví dụ L01"
            textField.autocapitalizationType = .allCharacters
            textField.text = court?.locationId
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
            textField.text = court?.status.rawValue.lowercased()
        }

        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: isEditing ? "Lưu" : "Thêm", style: .default, handler: { [weak self, weak alert] _ in
            guard let self, let alert else { return }
            self.submitCourtForm(alert: alert, editingCourt: court)
        }))

        present(alert, animated: true)
    }

    private func submitCourtForm(alert: UIAlertController, editingCourt: Court?) {
        let values = alert.textFields?.map { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" } ?? []
        guard values.count == 5 else { return }

        let name = values[0]
        let typeText = values[1].lowercased()
        let locationId = values[2].uppercased()
        let priceText = values[3]
        let statusText = values[4].lowercased()

        guard name.isEmpty == false,
              locationId.isEmpty == false,
              let price = Double(priceText),
              price > 0,
              let type = Self.courtType(from: typeText),
              let status = Self.courtStatus(from: statusText) else {
            showAlert(title: "Dữ liệu không hợp lệ", message: "Vui lòng nhập đúng loại sân, trạng thái và giá hợp lệ.")
            return
        }

        if let id = editingCourt?.id {
            store.updateCourt(id: id, name: name, type: type, locationId: locationId, pricePerHour: price, status: status)
        } else {
            store.createCourt(name: name, type: type, locationId: locationId, pricePerHour: price, status: status)
        }

        loadData()
    }

    private static func courtType(from value: String) -> CourtType? {
        switch value {
        case "single":
            return .single
        case "double":
            return .double
        case "vip":
            return .vip
        default:
            return nil
        }
    }

    private static func courtStatus(from value: String) -> CourtStatus? {
        switch value {
        case "active":
            return .active
        case "maintenance":
            return .maintenance
        default:
            return nil
        }
    }
}

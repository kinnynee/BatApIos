import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var legacyHeaderView: UIView!
    @IBOutlet weak var legacyOverlayButtonOne: UIButton!
    @IBOutlet weak var legacyOverlayButtonTwo: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var allPayments: [PaymentInfo] = []
    var displayedPayments: [PaymentInfo] = []

    private let store = AppMockStore.shared
    private let bookingsService = BackendBookingsService.shared
    private let emptyStateLabel = UILabel()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureLayout()
        configureAppearance()
        tableView.delegate = self
        tableView.dataSource = self
        configureEmptyState()

        loadPayments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadPayments()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func loadPayments() {
        Task { [weak self] in
            guard let self else { return }

            let userId = BackendAuthService.shared.restorePersistedUser()?.id ?? store.currentUser?.id
            guard let userId, !userId.isEmpty else {
                await MainActor.run {
                    self.allPayments = []
                    self.filterData(by: .success)
                }
                return
            }

            do {
                let bookings = try await bookingsService.fetchBookings(userId: userId)
                let payments = bookings.map(bookingsService.paymentInfo(from:))
                await MainActor.run {
                    self.allPayments = payments
                    let selectedStatus = OrderStatus(rawValue: self.segmentedControl.selectedSegmentIndex) ?? .success
                    self.filterData(by: selectedStatus)
                }
            } catch {
                await MainActor.run {
                    self.allPayments = self.store.paymentHistory()
                    let selectedStatus = OrderStatus(rawValue: self.segmentedControl.selectedSegmentIndex) ?? .success
                    self.filterData(by: selectedStatus)
                    self.showAlert(title: "Không tải được lịch sử", message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let selectedStatus = OrderStatus(rawValue: sender.selectedSegmentIndex) ?? .success
        filterData(by: selectedStatus)
    }

    func filterData(by status: OrderStatus) {
        displayedPayments = allPayments.filter { $0.status == status }
        emptyStateLabel.isHidden = !displayedPayments.isEmpty
        tableView.reloadData()
    }

    private func configureLayout() {
        legacyHeaderView?.isHidden = true
        legacyOverlayButtonOne?.isHidden = true
        legacyOverlayButtonTwo?.isHidden = true

        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(red: 0.06, green: 0.13, blue: 0.10, alpha: 1)
        titleLabel.text = "Lịch sử thanh toán"

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = UIColor(red: 0.06, green: 0.13, blue: 0.10, alpha: 1)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let canGoBack = (navigationController?.viewControllers.count ?? 0) > 1 || presentingViewController != nil
        backButton.isHidden = !canGoBack

        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(backButton)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor, constant: 24),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureAppearance() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1)

        segmentedControl.removeAllSegments()
        [OrderStatus.success, .pending, .cancelled].enumerated().forEach { index, status in
            segmentedControl.insertSegment(withTitle: status.title, at: index, animated: false)
        }
        segmentedControl.selectedSegmentIndex = OrderStatus.success.rawValue
        segmentedControl.selectedSegmentTintColor = UIColor(red: 0.09, green: 0.14, blue: 0.13, alpha: 1)
        segmentedControl.backgroundColor = .white
        segmentedControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: UIColor.white
        ], for: .selected)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 24, right: 0)
        tableView.showsVerticalScrollIndicator = false
    }

    private func configureEmptyState() {
        emptyStateLabel.text = "Chưa có đơn nào trong mục này.\nHãy thử đổi trạng thái hoặc tạo booking mới."
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        tableView.backgroundView = emptyStateLabel
        emptyStateLabel.isHidden = true
    }

    @objc private func backButtonTapped() {
        handleBackNavigation()
    }
}

extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedPayments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentTableViewCell else {
            return UITableViewCell()
        }

        let paymentInfo = displayedPayments[indexPath.row]
        cell.configure(with: paymentInfo)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        118
    }
}

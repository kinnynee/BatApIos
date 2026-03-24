import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var allPayments: [PaymentInfo] = []
    
    var displayedPayments: [PaymentInfo] = []
    private let store = AppMockStore.shared
    private let emptyStateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        configureEmptyState()
        
        loadPayments()
        filterData(by: .success)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPayments()
        let selectedStatus = OrderStatus(rawValue: segmentedControl.selectedSegmentIndex) ?? .success
        filterData(by: selectedStatus)
    }

    func loadPayments() {
        allPayments = store.paymentHistory()
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

    private func configureEmptyState() {
        emptyStateLabel.text = "Chưa có lịch sử đặt sân cho trạng thái này."
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        tableView.backgroundView = emptyStateLabel
        emptyStateLabel.isHidden = true
    }
}

extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedPayments.count
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
        return 80
    }
}

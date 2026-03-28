import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var allPayments: [PaymentInfo] = []
    
    var displayedPayments: [PaymentInfo] = []
    private let store = AppMockStore.shared
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Cập nhật màu sắc cho SegmentedControl
        segmentedControl.selectedSegmentTintColor = themeGreen
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
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
        tableView.reloadData()
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

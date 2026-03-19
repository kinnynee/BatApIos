import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var allPayments: [PaymentInfo] = []
    
    var displayedPayments: [PaymentInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupMockData()
        
        filterData(by: .success)
    }
    
    func setupMockData() {
        allPayments = [
            PaymentInfo(productImage: UIImage(named: "item1"), productName: "Áo thun", price: "500.000 vnđ", status: .success),
            PaymentInfo(productImage: UIImage(named: "item2"), productName: "Quần Jeans", price: "300.000 vnđ", status: .success),
            PaymentInfo(productImage: UIImage(named: "item3"), productName: "Giày Sneaker", price: "1.200.000 vnđ", status: .pending),
            PaymentInfo(productImage: UIImage(named: "item4"), productName: "Balo", price: "400.000 vnđ", status: .cancelled)
        ]
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

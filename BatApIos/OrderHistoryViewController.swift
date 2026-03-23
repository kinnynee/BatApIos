//
//  OrderHistoryViewController.swift
//  BatApIos
//
//  Created by Trần Kiên on 11/3/26.
//
import UIKit

class PaymentViewController: UIViewController {

    // Nối các Outlet từ Storyboard
    @IBOutlet weak var segmentedControl: UISegmentedControl! // Nối với thanh Thành Công/Đang đặt/Hủy
    @IBOutlet weak var tableView: UITableView!
    
    // Dữ liệu giả lập (Mock data)
    var allPayments: [PaymentInfo] = []
    
    // Dữ liệu đang được hiển thị trên TableView (sau khi lọc)
    var displayedPayments: [PaymentInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Thiết lập Delegate và DataSource cho TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Tạo dữ liệu mẫu
        setupMockData()
        
        // Hiển thị mặc định tab đầu tiên (Thành công)
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

    // Hàm được gọi khi người dùng bấm chuyển tab trên Segmented Control
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        let selectedStatus = OrderStatus(rawValue: sender.selectedSegmentIndex) ?? .success
        filterData(by: selectedStatus)
    }
    
    // Hàm lọc dữ liệu và làm mới TableView
    func filterData(by status: OrderStatus) {
        displayedPayments = allPayments.filter { $0.status == status }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Khai báo số lượng dòng dựa trên mảng đã lọc
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedPayments.count
    }
    
    // Hiển thị dữ liệu lên Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Lưu ý: Đặt Identifier của Prototype Cell trong Storyboard là "PaymentCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as? PaymentTableViewCell else {
            return UITableViewCell()
        }
        
        let paymentInfo = displayedPayments[indexPath.row]
        cell.configure(with: paymentInfo)
        
        return cell
    }
    
    // Khai báo chiều cao của Cell (có thể tùy chỉnh lại theo thiết kế của bạn)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

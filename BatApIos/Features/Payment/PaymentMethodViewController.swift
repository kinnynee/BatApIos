import UIKit

final class PaymentMethodViewController: UIViewController {

    // MARK: - Instantiation Helpers
    static let storyboardName = "Main"
    static let storyboardID = "PaymentMethodVC"

    /// Tạo PaymentMethodViewController từ Storyboard và truyền sẵn dữ liệu cần thiết
    /// - Parameters:
    ///   - amount: Số tiền cần thanh toán
    ///   - bookingId: Mã đặt sân (nếu đã có sẵn). Nếu nil sẽ dùng giá trị mặc định trong VC
    /// - Returns: PaymentMethodViewController đã được cấu hình hoặc nil nếu không tìm thấy trong Storyboard
    static func instantiate(amount: Double, bookingId: String? = nil) -> PaymentMethodViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: storyboardID) as? PaymentMethodViewController else {
            return nil
        }
        vc.amountToPay = amount
        if let bookingId { vc.bookingId = bookingId }
        return vc
    }

    /// Cho phép cấu hình lại số tiền/mã đặt sân sau khi đã khởi tạo
    func configure(amount: Double, bookingId: String? = nil) {
        self.amountToPay = amount
        if let bookingId { self.bookingId = bookingId }
        if isViewLoaded {
            amountLabel.text = Self.currencyFormatter.string(from: NSNumber(value: amount)) ?? "0 đ"
            bookingIdLabel.text = self.bookingId
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var bookingIdLabel: UILabel!

    @IBOutlet private weak var checkATM: UIImageView!
    @IBOutlet private weak var checkMomo: UIImageView!
    @IBOutlet private weak var checkTransfer: UIImageView!
    @IBOutlet private weak var checkVisa: UIImageView!
    @IBOutlet private weak var checkZalo: UIImageView!

    @IBOutlet private weak var viewATM: UIView!
    @IBOutlet private weak var viewMomo: UIView!
    @IBOutlet private weak var viewTransfer: UIView!
    @IBOutlet private weak var viewVisa: UIView!
    @IBOutlet private weak var viewZalo: UIView!
    
    // BỔ SUNG: Nút xác nhận thanh toán ở dưới cùng
    @IBOutlet private weak var confirmButton: UIButton!

    // MARK: - Public Variables (Biến để màn hình trước truyền dữ liệu vào)
    var amountToPay: Double = 0
    var bookingId: String = "BK-\(Int.random(in: 1000...9999))-2024" // Tạm thời tạo ID ngẫu nhiên

    // MARK: - State
    private enum PaymentMethod: CaseIterable {
        case atm
        case momo
        case transfer
        case visa
        case zalo
    }

    private var selectedMethod: PaymentMethod = .momo
    private let store = AppMockStore.shared

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updateSelectionUI()
    }

    // MARK: - Setup
    private func configureUI() {
        amountLabel.text = Self.currencyFormatter.string(from: NSNumber(value: amountToPay)) ?? "0 đ"
        bookingIdLabel.text = bookingId

        let mappings: [(UIView, PaymentMethod)] = [
            (viewATM, .atm),
            (viewMomo, .momo),
            (viewTransfer, .transfer),
            (viewVisa, .visa),
            (viewZalo, .zalo)
        ]

        mappings.forEach { view, method in
            view.layer.cornerRadius = 16
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.systemGray5.cgColor
            
            // Cho phép user tương tác với view
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paymentViewTapped(_:))))
            view.tag = method.hashValue
        }
    }

    // MARK: - Actions
    @objc private func paymentViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }

        switch view.tag {
        case PaymentMethod.atm.hashValue:
            selectedMethod = .atm
        case PaymentMethod.transfer.hashValue:
            selectedMethod = .transfer
        case PaymentMethod.visa.hashValue:
            selectedMethod = .visa
        case PaymentMethod.zalo.hashValue:
            selectedMethod = .zalo
        default:
            selectedMethod = .momo
        }

        updateSelectionUI()
    }
    
    // BỔ SUNG: Sự kiện khi bấm nút Xác nhận thanh toán ở cuối màn hình
    @IBAction private func confirmPaymentTapped(_ sender: UIButton) {
        do {
            let booking = try store.confirmPayment(for: bookingId, methodName: displayName(for: selectedMethod))
            let successViewController = BookingSuccessViewController()
            successViewController.bookingCode = booking.id
            navigationController?.pushViewController(successViewController, animated: true)
        } catch {
            let alert = UIAlertController(title: "Không thể thanh toán", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Đóng", style: .default))
            present(alert, animated: true)
        }
    }

    // MARK: - UI Updates
    private func updateSelectionUI() {
        let configurations: [(PaymentMethod, UIView, UIImageView)] = [
            (.atm, viewATM, checkATM),
            (.momo, viewMomo, checkMomo),
            (.transfer, viewTransfer, checkTransfer),
            (.visa, viewVisa, checkVisa),
            (.zalo, viewZalo, checkZalo)
        ]

        configurations.forEach { method, view, checkmark in
            let isSelected = method == selectedMethod
            view.layer.borderColor = isSelected ? UIColor.systemMint.cgColor : UIColor.systemGray5.cgColor
            view.backgroundColor = isSelected ? UIColor.systemMint.withAlphaComponent(0.08) : .systemBackground
            checkmark.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            checkmark.tintColor = isSelected ? .systemMint : .systemGray3
        }
    }
    
    // MARK: - Formatters
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private func displayName(for method: PaymentMethod) -> String {
        switch method {
        case .atm:
            return "ATM"
        case .momo:
            return "MoMo"
        case .transfer:
            return "Chuyển khoản"
        case .visa:
            return "Visa"
        case .zalo:
            return "ZaloPay"
        }
    }
}

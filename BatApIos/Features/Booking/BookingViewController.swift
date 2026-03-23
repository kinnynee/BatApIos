import UIKit

final class BookingViewController: UIViewController {

    // MARK: - UI Outlets
    @IBOutlet private weak var courtTypeSegment: UISegmentedControl!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var voucherTextField: UITextField!
    

    @IBOutlet private weak var paymentButton: UIButton!

    // MARK: - Constants & State
    private enum CourtType: Int {
        case double = 0
        case vip = 1
        case single = 2
        
        var basePrice: Double {
            switch self {
            case .double: return 150_000
            case .vip: return 220_000
            case .single: return 320_000
            }
        }
    }

    private let validDiscountCode = "GIAM50K"
    private let discountValue: Double = 50_000
    private let store = AppMockStore.shared
    
    private var isVoucherApplied = false {
        didSet {
            updatePrice()
        }
    }
    
    // Biến lưu tổng tiền hiện tại để truyền sang màn hình thanh toán
    private var currentTotalPrice: Double = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        updatePrice()
    }

    // MARK: - Setup UI
    private func configureUI() {
        voucherTextField.delegate = self
        courtTypeSegment.addTarget(self, action: #selector(courtTypeChanged(_:)), for: .valueChanged)
        setupHideKeyboardOnTap()
    }

    // MARK: - Actions
    @objc private func courtTypeChanged(_ sender: UISegmentedControl) {
        updatePrice()
    }
    
    // Sự kiện khi người dùng bấm nút Thanh Toán Ngay
    @IBAction private func paymentButtonTapped(_ sender: UIButton) {
        guard currentTotalPrice > 0 else {
            showAlert(title: "Lỗi", message: "Số tiền không hợp lệ để thanh toán.")
            return
        }

        do {
            let booking = try store.createBooking(
                courtTypeName: selectedCourtTypeTitle(),
                totalPrice: currentTotalPrice
            )

            if let paymentMethodVC = PaymentMethodViewController.instantiate(
                amount: currentTotalPrice,
                bookingId: booking.id
            ) {
                if let nav = self.navigationController {
                    nav.pushViewController(paymentMethodVC, animated: true)
                } else {
                    paymentMethodVC.modalPresentationStyle = .fullScreen
                    self.present(paymentMethodVC, animated: true)
                }
            } else {
                showAlert(title: "Lỗi", message: "Không thể mở màn hình thanh toán.")
            }
        } catch {
            showAlert(title: "Không thể tạo booking", message: error.localizedDescription)
        }
    }

    // MARK: - Logic Helpers
    private func updatePrice() {
        let selectedType = CourtType(rawValue: courtTypeSegment.selectedSegmentIndex) ?? .double
        var finalAmount = selectedType.basePrice

        if isVoucherApplied {
            finalAmount = max(finalAmount - discountValue, 0)
        }
        
        // Lưu lại tổng tiền vào biến trạng thái
        self.currentTotalPrice = finalAmount

        // Hiển thị lên màn hình
        priceLabel.text = Self.currencyFormatter.string(from: NSNumber(value: finalAmount))
    }

    private func applyVoucherIfNeeded() {
        let inputCode = voucherTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""

        guard !inputCode.isEmpty else {
            isVoucherApplied = false
            return
        }

        if inputCode == validDiscountCode {
            isVoucherApplied = true
            showAlert(title: "Áp dụng thành công", message: "Mã ưu đãi đã được tính vào tổng tiền.")
        } else {
            isVoucherApplied = false
            showAlert(title: "Không hợp lệ", message: "Mã ưu đãi chưa đúng hoặc đã hết hạn.")
        }
    }

    private func selectedCourtTypeTitle() -> String {
        let selectedType = CourtType(rawValue: courtTypeSegment.selectedSegmentIndex) ?? .double
        switch selectedType {
        case .double:
            return "Sân Double"
        case .vip:
            return "Sân VIP"
        case .single:
            return "Sân Single"
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
}

// MARK: - UITextFieldDelegate
extension BookingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        applyVoucherIfNeeded()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Utilities (Các hàm hỗ trợ)
private extension BookingViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func setupHideKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

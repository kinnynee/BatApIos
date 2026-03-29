import UIKit

final class CheckoutViewController: UIViewController {

    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var screenTitleLabel: UILabel!

    @IBOutlet private weak var courtImageView: UIImageView!
    @IBOutlet private weak var courtNameLabel: UILabel!
    @IBOutlet private weak var bookingTimeLabel: UILabel!
    @IBOutlet private weak var courtTypeLabel: UILabel!

    @IBOutlet private weak var applePayView: UIView!
    @IBOutlet private weak var applePayCheckmark: UIImageView!

    @IBOutlet private weak var cardPayView: UIView!
    @IBOutlet private weak var cardPayCheckmark: UIImageView!

    @IBOutlet private weak var eWalletPayView: UIView!
    @IBOutlet private weak var eWalletPayCheckmark: UIImageView!

    @IBOutlet private weak var totalAmountLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!

    var bookingDraft: CourtBookingDraft?
    var bookingInfo: [String: String] = [:]

    private enum CheckoutMethod: Int {
        case applePay = 0
        case card = 1
        case eWallet = 2
    }

    private var selectedPaymentMethod: CheckoutMethod = .applePay

    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let themeDark = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        populateCheckoutData()
        updateUIState()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)
        screenTitleLabel.text = "Checkout"

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)

        courtImageView.layer.cornerRadius = 16
        courtImageView.clipsToBounds = true
        courtImageView.backgroundColor = themeGreen.withAlphaComponent(0.12)
        courtImageView.image = UIImage(systemName: "figure.badminton")
        courtImageView.tintColor = themeGreen
    }

    private func setupGestures() {
        let mappings: [(UIView?, CheckoutMethod)] = [
            (applePayView, .applePay),
            (cardPayView, .card),
            (eWalletPayView, .eWallet)
        ]

        mappings.forEach { view, method in
            guard let view else { return }
            view.tag = method.rawValue
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapped(_:))))
        }
    }

    private func populateCheckoutData() {
        if let bookingDraft {
            courtNameLabel.text = bookingDraft.courtName
            bookingTimeLabel.text = "\(bookingDraft.dateDisplayText) • \(bookingDraft.timeDisplayText)"
            courtTypeLabel.text = bookingDraft.courtTypeName
            totalAmountLabel.text = Self.currencyFormatter.string(from: NSNumber(value: bookingDraft.totalPrice)) ?? "0 đ"
        } else {
            courtNameLabel.text = bookingInfo["Sân đấu"] ?? "Sân cầu lông"
            let dateText = bookingInfo["Ngày"] ?? "--/--/----"
            let timeText = bookingInfo["Giờ"] ?? "--:--"
            bookingTimeLabel.text = "\(dateText) • \(timeText)"
            courtTypeLabel.text = bookingInfo["Loại sân"] ?? "Sân tiêu chuẩn"
            totalAmountLabel.text = bookingInfo["Tổng tiền"] ?? "0 đ"
        }

        confirmButton.setTitle("Tiếp tục thanh toán", for: .normal)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }

    @objc private func paymentMethodTapped(_ sender: UITapGestureRecognizer) {
        guard
            let index = sender.view?.tag,
            let method = CheckoutMethod(rawValue: index)
        else {
            return
        }

        selectedPaymentMethod = method
        updateUIState()
    }

    @objc private func confirmButtonTapped() {
        do {
            let booking: AppStoreBookingRecord
            if let bookingDraft {
                booking = try AppStore.shared.createBooking(from: bookingDraft)
            } else {
                let amount = Self.parseCurrency(bookingInfo["Tổng tiền"])
                let courtName = bookingInfo["Sân đấu"] ?? "Sân cầu lông"
                booking = try AppStore.shared.createBooking(courtTypeName: courtName, totalPrice: amount)
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let paymentVC = storyboard.instantiateViewController(withIdentifier: "PaymentMethodVC") as? PaymentMethodViewController else {
                return
            }

            paymentVC.configure(amount: booking.totalPrice, bookingId: booking.id)

            if let nav = navigationController {
                nav.pushViewController(paymentVC, animated: true)
            } else {
                present(paymentVC, animated: true)
            }
        } catch {
            let alert = UIAlertController(
                title: "Không thể checkout",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Đóng", style: .default))
            present(alert, animated: true)
        }
    }

    private func updateUIState() {
        let views = [applePayView, cardPayView, eWalletPayView]
        let checkmarks = [applePayCheckmark, cardPayCheckmark, eWalletPayCheckmark]

        for (index, view) in views.enumerated() {
            let isSelected = index == selectedPaymentMethod.rawValue
            view?.layer.borderColor = isSelected ? themeGreen.cgColor : UIColor.systemGray5.cgColor
            view?.layer.borderWidth = isSelected ? 2 : 1
            view?.layer.cornerRadius = 16
            view?.backgroundColor = isSelected ? themeGreen.withAlphaComponent(0.08) : .white

            checkmarks[index]?.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            checkmarks[index]?.tintColor = isSelected ? themeGreen : .systemGray4
        }
    }

    private static func parseCurrency(_ text: String?) -> Double {
        guard let text else { return 0 }
        let normalized = text
            .replacingOccurrences(of: "đ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(normalized) ?? 0
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

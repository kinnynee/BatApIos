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
    private var currentLanguage: AppLanguage { AppLocalization.currentLanguage }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        populateCheckoutData()
        updateUIState()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)
        screenTitleLabel.text = text(.checkout)

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
            totalAmountLabel.text = currencyText(bookingDraft.totalPrice)
        } else {
            courtNameLabel.text = bookingInfo[text(.court)] ?? bookingInfo["Sân đấu"] ?? text(.badmintonCourt)
            let dateText = bookingInfo[text(.date)] ?? bookingInfo["Ngày"] ?? "--/--/----"
            let timeText = bookingInfo[text(.time)] ?? bookingInfo["Giờ"] ?? "--:--"
            bookingTimeLabel.text = "\(dateText) • \(timeText)"
            courtTypeLabel.text = bookingInfo[text(.courtType)] ?? bookingInfo["Loại sân"] ?? text(.standardCourt)
            totalAmountLabel.text = bookingInfo[text(.total)] ?? bookingInfo["Tổng tiền"] ?? (currentLanguage == .english ? "$0" : "0 đ")
        }

        confirmButton.setTitle(text(.continueToPayment), for: .normal)
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
                let amount = Self.parseCurrency(bookingInfo[text(.total)] ?? bookingInfo["Tổng tiền"])
                let courtName = bookingInfo[text(.court)] ?? bookingInfo["Sân đấu"] ?? text(.badmintonCourt)
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
                title: text(.unableToCheckout),
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: text(.close), style: .default))
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

    private func localized(_ vietnamese: String, _ english: String) -> String {
        AppLocalization.localized(vi: vietnamese, en: english)
    }

    private func text(_ key: AppLocalizedKey) -> String {
        AppLocalization.text(key)
    }

    private func currencyText(_ amount: Double) -> String {
        Self.currencyFormatter(for: currentLanguage).string(from: NSNumber(value: amount)) ?? (currentLanguage == .english ? "$0" : "0 đ")
    }

    private static func currencyFormatter(for language: AppLanguage) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: language == .english ? "en_US" : "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

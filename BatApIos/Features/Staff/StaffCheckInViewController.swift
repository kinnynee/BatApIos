import UIKit

final class StaffCheckInViewController: UIViewController {

    @IBOutlet private weak var bookingDetailsCard: UIView!
    @IBOutlet private weak var cameraPreviewView: UIView!
    @IBOutlet private weak var courtLabel: UILabel!
    @IBOutlet private weak var customerNameLabel: UILabel!
    @IBOutlet private weak var flashButton: UIButton!
    @IBOutlet private weak var manualCodeTextField: UITextField!
    @IBOutlet private weak var timeLabel: UILabel!

    private var isFlashEnabled = false
    private let store = AppStore.shared
    var prefilledBookingCode: String?
    private var pasteCodeButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if prefilledBookingCode == nil {
            manualCodeTextField.becomeFirstResponder()
        }
    }

    private func configureUI() {
        bookingDetailsCard.isHidden = true
        bookingDetailsCard.layer.borderColor = UIColor.systemGray5.cgColor
        cameraPreviewView.layer.cornerRadius = 20
        cameraPreviewView.clipsToBounds = true

        customerNameLabel.text = "Chưa có booking"
        courtLabel.text = "Quét hoặc nhập mã"
        timeLabel.text = "--:-- - --:--"

        manualCodeTextField.delegate = self
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        wireCheckInButtons()
        installPasteButtonIfNeeded()
        dismissKeyboardWhenTappedAround()

        if let prefilledBookingCode {
            manualCodeTextField.text = prefilledBookingCode
            lookupBooking()
        }
    }

    @objc private func toggleFlash() {
        isFlashEnabled.toggle()

        var configuration = flashButton.configuration
        configuration?.image = UIImage(systemName: isFlashEnabled ? "flashlight.off.fill" : "flashlight.on.fill")
        flashButton.configuration = configuration
    }

    @objc private func checkInButtonTapped() {
        lookupBooking()
        manualCodeTextField.resignFirstResponder()
    }

    @objc private func pasteCodeButtonTapped() {
        let pastedCode = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard pastedCode.isEmpty == false else {
            showAlert(title: "Chưa có mã", message: "Clipboard hiện chưa có mã booking để dán.")
            return
        }

        manualCodeTextField.text = pastedCode
        lookupBooking()
        manualCodeTextField.resignFirstResponder()
    }

    private func lookupBooking() {
        let manualCode = manualCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""

        guard !manualCode.isEmpty else {
            showAlert(title: "Thiếu mã", message: "Vui lòng nhập mã booking để kiểm tra.")
            return
        }

        do {
            let booking = try store.checkInBooking(code: manualCode)
            bookingDetailsCard.isHidden = false
            customerNameLabel.text = "Khách hàng: \(store.displayName(for: booking.userId))"
            courtLabel.text = booking.courtName
            timeLabel.text = Self.timeFormatter.string(from: booking.startTime) + " - " + Self.timeFormatter.string(from: booking.endTime)
            showAlert(title: "Check-in thành công", message: "Booking \(booking.id) đã được xác nhận vào sân.")
        } catch {
            bookingDetailsCard.isHidden = true
            customerNameLabel.text = "Chưa có booking"
            courtLabel.text = "Quét hoặc nhập mã"
            timeLabel.text = "--:-- - --:--"
            showAlert(title: "Không thể check-in", message: error.localizedDescription)
            return
        }
    }
}

extension StaffCheckInViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        lookupBooking()
        textField.resignFirstResponder()
        return true
    }
}

private extension StaffCheckInViewController {
    func wireCheckInButtons() {
        for button in view.allSubviews(ofType: UIButton.self) {
            let title = button.currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if title == "Check-in" {
                button.addTarget(self, action: #selector(checkInButtonTapped), for: .touchUpInside)
            }
        }
    }

    func installPasteButtonIfNeeded() {
        guard pasteCodeButton == nil else { return }
        guard let buttonStack = view.findView(withAccessibilityIdentifier: nil, matchingTitle: "Check-in")?.superview as? UIStackView else {
            return
        }

        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "Dán mã"
        configuration.image = UIImage(systemName: "doc.on.clipboard")
        configuration.imagePadding = 6
        configuration.cornerStyle = .large
        configuration.baseForegroundColor = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)
        configuration.baseBackgroundColor = UIColor.systemGray6
        button.configuration = configuration
        button.addTarget(self, action: #selector(pasteCodeButtonTapped), for: .touchUpInside)

        buttonStack.addArrangedSubview(button)
        pasteCodeButton = button
    }

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

private extension UIView {
    func allSubviews<T: UIView>(ofType type: T.Type) -> [T] {
        var matches = subviews.compactMap { $0 as? T }
        for subview in subviews {
            matches.append(contentsOf: subview.allSubviews(ofType: type))
        }
        return matches
    }

    func findView(withAccessibilityIdentifier accessibilityIdentifier: String? = nil, matchingTitle title: String) -> UIView? {
        if let button = self as? UIButton,
           button.currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines) == title {
            return button
        }

        for subview in subviews {
            if let match = subview.findView(withAccessibilityIdentifier: accessibilityIdentifier, matchingTitle: title) {
                return match
            }
        }
        return nil
    }
}

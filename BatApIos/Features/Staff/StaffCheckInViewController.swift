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
    private let store = AppMockStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        bookingDetailsCard.isHidden = false
        bookingDetailsCard.layer.borderColor = UIColor.systemGray5.cgColor
        cameraPreviewView.layer.cornerRadius = 20
        cameraPreviewView.clipsToBounds = true

        customerNameLabel.text = "Nguyen Van A"
        courtLabel.text = "Sân VIP 02"
        timeLabel.text = "18:00 - 19:30"

        manualCodeTextField.delegate = self
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        dismissKeyboardWhenTappedAround()
    }

    @objc private func toggleFlash() {
        isFlashEnabled.toggle()

        var configuration = flashButton.configuration
        configuration?.image = UIImage(systemName: isFlashEnabled ? "flashlight.off.fill" : "flashlight.on.fill")
        flashButton.configuration = configuration
    }

    private func lookupBooking() {
        let manualCode = manualCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""

        guard !manualCode.isEmpty else {
            showAlert(title: "Thiếu mã", message: "Vui lòng nhập mã booking để kiểm tra.")
            return
        }

        guard let booking = store.findBooking(code: manualCode) else {
            showAlert(title: "Không tìm thấy", message: "Mã booking không tồn tại trong hệ thống demo.")
            return
        }

        bookingDetailsCard.isHidden = false
        customerNameLabel.text = "Khách hàng: \(store.currentUser?.username ?? "Khách vãng lai")"
        courtLabel.text = booking.courtName
        timeLabel.text = Self.timeFormatter.string(from: booking.startTime) + " - " + Self.timeFormatter.string(from: booking.endTime)
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
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

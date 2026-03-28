
import UIKit

final class NewCourtBookingViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var screenTitleLabel: UILabel!
    
    // Scroll & Stack
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    // Date Selection
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var day1View: UIView!
    @IBOutlet weak var day2View: UIView!
    @IBOutlet weak var day3View: UIView!
    @IBOutlet weak var day4View: UIView!
    @IBOutlet weak var day5View: UIView!
    
    // Time Selection (Buttons)
    @IBOutlet weak var timeSlot1Button: UIButton!
    @IBOutlet weak var timeSlot2Button: UIButton!
    @IBOutlet weak var timeSlot3Button: UIButton!
    @IBOutlet weak var timeSlot4Button: UIButton!
    @IBOutlet weak var timeSlot5Button: UIButton!
    @IBOutlet weak var timeSlot6Button: UIButton!
    
    // Court Type
    @IBOutlet weak var standardTypeView: UIView!
    @IBOutlet weak var vipTypeView: UIView!
    
    // Recurrence
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    // Voucher
    @IBOutlet weak var voucherTextField: UITextField!
    @IBOutlet weak var applyVoucherButton: UIButton!
    
    // Footer
    @IBOutlet weak var confirmButton: UIButton!
    
    // Programmatic UI for Court Number Selection
    private let courtSelectionLabel = UILabel()
    private let courtSelectionStack = UIStackView()
    private var courtButtons: [UIButton] = []
    private var selectedCourtNumber: Int = 1 // Default Sân 1

    
    private var selectedDateIndex: Int = 1 // Default index 2 (day2View is selected in SB)
    private var selectedTimeSlot: String? = "11:00 AM" // Default as per SB
    private var isVipSelected: Bool = false
    private var appliedVoucherCode: String?
    private var appliedDiscountAmount: Double = 0
    var prefilledVoucherCode: String?
    
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let themeDark = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)
    private let supportedVouchers: [String: Double] = [
        "GIAM50K": 50_000,
        "MORNING30": 30_000,
        "VIP20": 20_000
    ]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuth()
    }

    private func checkAuth() {
        if AppMockStore.shared.currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            
            // Callback khi đăng nhập thành công
            loginVC.onLoginSuccess = { [weak loginVC] in
                loginVC?.dismiss(animated: true) {
                    // Refresh data after login if needed
                }
            }
            
            present(loginVC, animated: true)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCourtSelectionUI()
        setupGestures()
        updateUIState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)
        
        // Setup Button Actions
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        applyVoucherButton.addTarget(self, action: #selector(applyVoucherTapped), for: .touchUpInside)
        
        // Setup Time Slots
        let timeButtons = [timeSlot1Button, timeSlot2Button, timeSlot3Button, timeSlot4Button, timeSlot5Button, timeSlot6Button]
        for (index, button) in timeButtons.enumerated() {
            button?.tag = index
            button?.addTarget(self, action: #selector(timeSlotTapped(_:)), for: .touchUpInside)
        }
        
        confirmButton.setTitle("Tiếp tục", for: .normal)
        voucherTextField.placeholder = "Nhập mã ưu đãi"
        selectedDateLabel.text = Self.dateDisplayStrings[selectedDateIndex]

        if let prefilledVoucherCode {
            voucherTextField.text = prefilledVoucherCode
            applyVoucherTapped()
        }
    }
    
    private func setupCourtSelectionUI() {
        // Label
        courtSelectionLabel.text = "Chọn Sân"
        courtSelectionLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        // Stack
        courtSelectionStack.axis = .horizontal
        courtSelectionStack.spacing = 10
        courtSelectionStack.distribution = .fillEqually
        
        // Buttons
        for i in 1...3 {
            let btn = UIButton(type: .system)
            btn.setTitle("Sân \(i)", for: .normal)
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 1
            btn.tag = i
            btn.addTarget(self, action: #selector(courtNumberTapped(_:)), for: .touchUpInside)
            courtButtons.append(btn)
            courtSelectionStack.addArrangedSubview(btn)
        }
        
        // Insert into mainStackView
        mainStackView.insertArrangedSubview(courtSelectionLabel, at: 0)
        mainStackView.insertArrangedSubview(courtSelectionStack, at: 1)
        mainStackView.setCustomSpacing(16, after: courtSelectionStack)
    }
    
    private func setupGestures() {
        // Date Views
        let dateViews = [day1View, day2View, day3View, day4View, day5View]
        for (index, view) in dateViews.enumerated() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dayViewTapped(_:)))
            view?.addGestureRecognizer(tap)
            view?.tag = index
            view?.isUserInteractionEnabled = true
        }
        
        // Court Types
        let standardTap = UITapGestureRecognizer(target: self, action: #selector(courtTypeTapped(_:)))
        standardTypeView.addGestureRecognizer(standardTap)
        standardTypeView.tag = 0
        standardTypeView.isUserInteractionEnabled = true
        
        let vipTap = UITapGestureRecognizer(target: self, action: #selector(courtTypeTapped(_:)))
        vipTypeView.addGestureRecognizer(vipTap)
        vipTypeView.tag = 1
        vipTypeView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc private func dayViewTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        selectedDateIndex = index
        updateUIState()
        
        // Update label (demo)
        selectedDateLabel.text = Self.dateDisplayStrings[index]
    }
    
    @objc private func timeSlotTapped(_ sender: UIButton) {
        selectedTimeSlot = sender.titleLabel?.text
        updateUIState()
    }

    @objc private func courtNumberTapped(_ sender: UIButton) {
        selectedCourtNumber = sender.tag
        updateUIState()
    }
    
    @objc private func courtTypeTapped(_ sender: UITapGestureRecognizer) {
        isVipSelected = (sender.view?.tag == 1)
        updateUIState()
    }
    
    @objc private func confirmButtonTapped() {
        let summaryVC = BookingSummaryViewController()
        summaryVC.bookingDraft = makeBookingDraft()
        
        if let nav = navigationController {
            nav.pushViewController(summaryVC, animated: true)
        } else {
            present(summaryVC, animated: true)
        }
    }

    @objc private func applyVoucherTapped() {
        let inputCode = voucherTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""

        guard inputCode.isEmpty == false else {
            appliedVoucherCode = nil
            appliedDiscountAmount = 0
            showAlert(title: "Thiếu mã", message: "Vui lòng nhập mã khuyến mãi.")
            return
        }

        guard let discount = supportedVouchers[inputCode] else {
            appliedVoucherCode = nil
            appliedDiscountAmount = 0
            showAlert(title: "Mã không hợp lệ", message: "Mã khuyến mãi chưa đúng hoặc đã hết hạn.")
            return
        }

        appliedVoucherCode = inputCode
        appliedDiscountAmount = discount
        showAlert(title: "Áp dụng thành công", message: "Ưu đãi \(Int(discount))đ đã được áp dụng cho đơn đặt sân.")
    }
    
    // MARK: - UI Updates
    
    private func updateUIState() {
        // Update Date Selection UI
        let dateViews = [day1View, day2View, day3View, day4View, day5View]
        for (index, view) in dateViews.enumerated() {
            let isSelected = (index == selectedDateIndex)
            view?.backgroundColor = isSelected ? themeGreen : .white
            view?.layer.borderWidth = isSelected ? 0 : 1
            view?.layer.borderColor = isSelected ? nil : UIColor.systemGray5.cgColor
        }
        
        // Update Time Slots UI
        let timeButtons = [timeSlot1Button, timeSlot2Button, timeSlot3Button, timeSlot4Button, timeSlot5Button, timeSlot6Button]
        for button in timeButtons {
            let isSelected = (button?.titleLabel?.text == selectedTimeSlot)
            button?.backgroundColor = isSelected ? themeGreen : .white
            button?.tintColor = isSelected ? themeDark : .black
            button?.layer.borderWidth = isSelected ? 0 : 1
            button?.layer.borderColor = isSelected ? nil : UIColor.systemGray5.cgColor
        }
        
        // Update Court Type
        standardTypeView.layer.borderWidth = isVipSelected ? 1 : 2
        standardTypeView.layer.borderColor = isVipSelected ? UIColor.systemGray5.cgColor : themeGreen.cgColor
        
        vipTypeView.layer.borderWidth = isVipSelected ? 2 : 1
        vipTypeView.layer.borderColor = isVipSelected ? themeGreen.cgColor : UIColor.systemGray5.cgColor
        
        // Update Court Number UI
        for btn in courtButtons {
            let isSelected = (btn.tag == selectedCourtNumber)
            btn.backgroundColor = isSelected ? themeGreen : .white
            btn.tintColor = isSelected ? .white : .black
            btn.layer.borderColor = isSelected ? themeGreen.cgColor : UIColor.systemGray5.cgColor
        }
    }

    private func makeBookingDraft() -> CourtBookingDraft {
        let bookingDate = Self.bookingDates[selectedDateIndex]
        let selectedTime = selectedTimeSlot ?? "11:00"
        let startTime = Self.timeFormatter24.date(from: selectedTime)
            ?? Self.timeFormatter12.date(from: selectedTime)
            ?? bookingDate
        let calendar = Calendar.current
        let bookingStart = calendar.date(
            bySettingHour: calendar.component(.hour, from: startTime),
            minute: calendar.component(.minute, from: startTime),
            second: 0,
            of: bookingDate
        ) ?? bookingDate
        let bookingEnd = calendar.date(byAdding: .minute, value: 90, to: bookingStart) ?? bookingStart
        let courtType = isVipSelected ? "VIP" : "Tiêu chuẩn"
        let basePrice = isVipSelected ? 220_000.0 : 150_000.0
        let finalTotal = max(basePrice - appliedDiscountAmount, 0)
        let courtName = "Sân \(selectedCourtNumber) - \(courtType)"

        return CourtBookingDraft(
            courtName: courtName,
            courtNumber: selectedCourtNumber,
            courtTypeName: courtType,
            bookingDate: bookingDate,
            dateDisplayText: selectedDateLabel.text ?? Self.dateDisplayStrings[selectedDateIndex],
            timeDisplayText: selectedTime,
            startTime: bookingStart,
            endTime: bookingEnd,
            voucherCode: appliedVoucherCode,
            discountAmount: appliedDiscountAmount,
            totalPrice: finalTotal
        )
    }
}

private extension NewCourtBookingViewController {
    static let bookingDates: [Date] = {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        return (0..<5).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
    }()

    static let dateDisplayStrings: [String] = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "'Ngày' d 'thg' M"
        return bookingDates.map { formatter.string(from: $0) }
    }()

    static let timeFormatter24: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let timeFormatter12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

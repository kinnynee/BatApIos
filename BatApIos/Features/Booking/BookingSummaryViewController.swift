
import UIKit

final class BookingSummaryViewController: UIViewController {

    // MARK: - Properties
    var bookingInfo: [String: String] = [:]
    var bookingDraft: CourtBookingDraft?
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let themeDark = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)

    // MARK: - UI Components
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    
    private let cardView = UIView()
    private let infoStackView = UIStackView()
    private let confirmButton = UIButton(type: .system)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)
        
        // 1. Header
        headerView.backgroundColor = .clear
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = themeDark
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Chi tiết đặt sân"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = themeDark
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Card View
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 8
        view.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // 3. Info Stack
        infoStackView.axis = .vertical
        infoStackView.spacing = 20
        cardView.addSubview(infoStackView)
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 4. Confirm Button
        confirmButton.setTitle("Tiến hành thanh toán", for: .normal)
        confirmButton.backgroundColor = themeGreen
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        confirmButton.layer.cornerRadius = 14
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            cardView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            infoStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func populateData() {
        if let bookingDraft {
            bookingInfo = [
                "Sân": bookingDraft.courtName,
                "Số sân": "Sân \(bookingDraft.courtNumber)",
                "Ngày": bookingDraft.dateDisplayText,
                "Giờ": bookingDraft.timeDisplayText,
                "Loại sân": bookingDraft.courtTypeName,
                "Voucher": bookingDraft.voucherCode ?? "Không áp dụng",
                "Tổng tiền": Self.currencyFormatter.string(from: NSNumber(value: bookingDraft.totalPrice)) ?? "0 đ"
            ]
        }

        let keys = ["Sân", "Số sân", "Ngày", "Giờ", "Loại sân", "Voucher", "Tổng tiền"]
        for key in keys {
            if let value = bookingInfo[key] {
                addInfoRow(label: key, value: value)
            }
        }
    }

    private func addInfoRow(label: String, value: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        
        let lblKey = UILabel()
        lblKey.text = label
        lblKey.font = .systemFont(ofSize: 14)
        lblKey.textColor = .secondaryLabel
        
        let lblVal = UILabel()
        lblVal.text = value
        lblVal.font = .systemFont(ofSize: 15, weight: .semibold)
        lblVal.textColor = themeDark
        
        row.addArrangedSubview(lblKey)
        row.addArrangedSubview(lblVal)
        infoStackView.addArrangedSubview(row)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }

    @objc private func confirmTapped() {
        do {
            let booking: AppStoreBookingRecord
            if let bookingDraft {
                booking = try AppStore.shared.createBooking(from: bookingDraft)
            } else {
                let amountString = bookingInfo["Tổng tiền"]?.replacingOccurrences(of: ".000đ", with: "000").replacingOccurrences(of: "đ", with: "").replacingOccurrences(of: ".", with: "") ?? "0"
                let amount = Double(amountString) ?? 0
                let courtName = bookingInfo["Sân"] ?? "Sân Cầu Lông"
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
            let alert = UIAlertController(title: "Lỗi", message: "Không thể tạo đặt sân: \(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Đóng", style: .default))
            present(alert, animated: true)
        }
    }
}

private extension BookingSummaryViewController {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

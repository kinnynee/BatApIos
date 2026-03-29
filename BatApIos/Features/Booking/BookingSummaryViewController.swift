
import UIKit

final class BookingSummaryViewController: UIViewController {

    // MARK: - Properties
    var bookingInfo: [String: String] = [:]
    var bookingDraft: CourtBookingDraft?
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let themeDark = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)
    private var currentLanguage: AppLanguage { AppLocalization.currentLanguage }

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
        
        titleLabel.text = text(.bookingDetails)
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
        confirmButton.setTitle(text(.proceedToPayment), for: .normal)
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
                text(.court): bookingDraft.courtName,
                text(.courtNumber): "\(text(.court)) \(bookingDraft.courtNumber)",
                text(.date): bookingDraft.dateDisplayText,
                text(.time): bookingDraft.timeDisplayText,
                text(.courtType): bookingDraft.courtTypeName,
                text(.voucher): bookingDraft.voucherCode ?? text(.notApplied),
                text(.total): currencyText(bookingDraft.totalPrice)
            ]
        }

        let keys = [
            text(.court),
            text(.courtNumber),
            text(.date),
            text(.time),
            text(.courtType),
            text(.voucher),
            text(.total)
        ]
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let checkoutVC = storyboard.instantiateViewController(withIdentifier: "CheckoutVC") as? CheckoutViewController else {
            return
        }

        checkoutVC.bookingDraft = bookingDraft
        checkoutVC.bookingInfo = bookingInfo

        if let nav = navigationController {
            nav.pushViewController(checkoutVC, animated: true)
        } else {
            present(checkoutVC, animated: true)
        }
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
}

private extension BookingSummaryViewController {
    static func currencyFormatter(for language: AppLanguage) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: language == .english ? "en_US" : "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }
}

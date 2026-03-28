
import UIKit

final class CheckoutViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var screenTitleLabel: UILabel!
    
    // Summary Card
    @IBOutlet weak var courtImageView: UIImageView!
    @IBOutlet weak var courtNameLabel: UILabel!
    @IBOutlet weak var bookingTimeLabel: UILabel!
    @IBOutlet weak var courtTypeLabel: UILabel!
    
    // Payment Methods
    @IBOutlet weak var applePayView: UIView!
    @IBOutlet weak var applePayCheckmark: UIImageView!
    
    @IBOutlet weak var cardPayView: UIView!
    @IBOutlet weak var cardPayCheckmark: UIImageView!
    
    @IBOutlet weak var eWalletPayView: UIView!
    @IBOutlet weak var eWalletPayCheckmark: UIImageView!
    
    // Total
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    // Footer
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Properties
    
    private var selectedPaymentMethod: Int = 0 // 0: Apple Pay, 1: Card, 2: E-wallet
    
    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
    private let themeDark = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1.0)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        updateUIState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)
        
        // Setup Button Actions
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        // Mock data
        courtNameLabel.text = "Sân Cầu Lông CodeForApp #1"
        bookingTimeLabel.text = "22 Tháng 3, 2024 • 11:00 AM"
        courtTypeLabel.text = "Sân Tiêu chuẩn"
        totalAmountLabel.text = "$34.00"
    }
    
    private func setupGestures() {
        let appleTap = UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapped(_:)))
        applePayView.addGestureRecognizer(appleTap)
        applePayView.tag = 0
        applePayView.isUserInteractionEnabled = true
        
        let cardTap = UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapped(_:)))
        cardPayView.addGestureRecognizer(cardTap)
        cardPayView.tag = 1
        cardPayView.isUserInteractionEnabled = true
        
        let walletTap = UITapGestureRecognizer(target: self, action: #selector(paymentMethodTapped(_:)))
        eWalletPayView.addGestureRecognizer(walletTap)
        eWalletPayView.tag = 2
        eWalletPayView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc private func paymentMethodTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        selectedPaymentMethod = index
        updateUIState()
    }
    
    @objc private func confirmButtonTapped() {
        print("Payment confirmed with method \(selectedPaymentMethod)")
        // In a real app, this would trigger payment processing
        // For demo, we navigate to Success
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let successVC = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as? PaymentViewController {
            navigationController?.pushViewController(successVC, animated: true)
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUIState() {
        let views = [applePayView, cardPayView, eWalletPayView]
        let checkmarks = [applePayCheckmark, cardPayCheckmark, eWalletPayCheckmark]
        
        for (index, view) in views.enumerated() {
            let isSelected = (index == selectedPaymentMethod)
            view?.layer.borderColor = isSelected ? themeGreen.cgColor : UIColor.systemGray5.cgColor
            view?.layer.borderWidth = isSelected ? 2 : 1
            
            checkmarks[index]?.image = UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            checkmarks[index]?.tintColor = isSelected ? themeGreen : .systemGray4
        }
    }
}

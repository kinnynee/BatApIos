import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    private let authService = FirebaseAuthService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        handleBackNavigation()
    }
    
    @IBAction func sendRequestTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập Email của bạn.")
            return
        }
        
        if !isValidEmail(email) {
            showAlert(title: "Lỗi", message: "Định dạng Email không hợp lệ.")
            return
        }
        
        Task { [weak self] in
            guard let self else { return }

            do {
                try await authService.sendPasswordReset(email: email)
                await MainActor.run {
                    self.showAlert(title: "Đã gửi", message: "Firebase đã gửi email đặt lại mật khẩu cho \(email).") {
                        self.handleBackNavigation()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể xử lý", message: error.localizedDescription)
                }
            }
        }
    }
}

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    private let store = AppMockStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
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
        
        do {
            let message = try store.sendResetPassword(email: email)
            let alert = UIAlertController(
                title: "Đã gửi",
                message: "\(message)\n\nBạn có muốn đặt lại mật khẩu ngay không?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Để sau", style: .cancel, handler: { _ in
                self.dismiss(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Đặt lại ngay", style: .default, handler: { _ in
                let resetViewController = ResetPasswordViewController()
                resetViewController.emailAddress = email
                resetViewController.modalPresentationStyle = .fullScreen
                self.present(resetViewController, animated: true)
            }))
            present(alert, animated: true)
        } catch {
            showAlert(title: "Không thể xử lý", message: error.localizedDescription)
        }
    }
}

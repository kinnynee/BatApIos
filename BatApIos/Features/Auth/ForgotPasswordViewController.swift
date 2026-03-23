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
            showAlert(title: "Đã gửi", message: message) {
                self.dismiss(animated: true)
            }
        } catch {
            showAlert(title: "Không thể xử lý", message: error.localizedDescription)
        }
    }
}

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!

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
        
        showAlert(title: "Đã gửi", message: "Hướng dẫn khôi phục mật khẩu đã được gửi đến \(email).") {
            self.dismiss(animated: true)
        }
    }
}

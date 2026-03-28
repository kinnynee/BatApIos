import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordEyeButton: UIButton!
    
    var isPassVisible = false
    private let store = AppMockStore.shared
    
    /// Callback sau khi đăng ký thành công
    var onRegisterSuccess: ((User) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        passwordEyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPassVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPassVisible
        confirmPasswordTextField.isSecureTextEntry = !isPassVisible
        let icon = isPassVisible ? "eye" : "eye.slash"
        passwordEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let pass = passwordTextField.text, !pass.isEmpty,
              let confirm = confirmPasswordTextField.text, !confirm.isEmpty else {
            showAlert(title: "Thiếu thông tin", message: "Vui lòng điền đầy đủ các trường.")
            return
        }
        
        if !isValidEmail(email) {
            showAlert(title: "Lỗi", message: "Email không hợp lệ.")
            return
        }
        
        if pass.count < 8 {
            showAlert(title: "Mật khẩu yếu", message: "Mật khẩu phải có ít nhất 8 ký tự.")
            return
        }
        
        if pass != confirm {
            showAlert(title: "Lỗi", message: "Mật khẩu xác nhận không khớp.")
            return
        }
        
        do {
            let user = try store.register(name: name, email: email, password: pass)
            showAlert(title: "Chào mừng!", message: "Tạo tài khoản SmashBooking thành công.") {
                if let onRegisterSuccess = self.onRegisterSuccess {
                    onRegisterSuccess(user)
                } else {
                    self.dismiss(animated: true)
                }
            }
        } catch {
            showAlert(title: "Không thể đăng ký", message: error.localizedDescription)
        }
    }
}

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordEyeButton: UIButton!
    @IBOutlet weak var confirmPasswordEyeButton: UIButton!
    
    var isNewPassVisible = false
    var isConfirmPassVisible = false
    var emailAddress: String?
    private let store = AppMockStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        handleBackNavigation()
    }
    
    @IBAction func toggleNewPasswordVisibility(_ sender: UIButton) {
        isNewPassVisible.toggle()
        newPasswordTextField.isSecureTextEntry = !isNewPassVisible
        let icon = isNewPassVisible ? "eye" : "eye.slash"
        newPasswordEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @IBAction func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        isConfirmPassVisible.toggle()
        confirmPasswordTextField.isSecureTextEntry = !isConfirmPassVisible
        let icon = isConfirmPassVisible ? "eye" : "eye.slash"
        confirmPasswordEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        guard let newPass = newPasswordTextField.text, !newPass.isEmpty,
              let confirmPass = confirmPasswordTextField.text, !confirmPass.isEmpty else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập đầy đủ mật khẩu mới.")
            return
        }
        
        if newPass.count < 8 {
            showAlert(title: "Mật khẩu yếu", message: "Mật khẩu phải có ít nhất 8 ký tự.")
            return
        }
        
        if newPass != confirmPass {
            showAlert(title: "Lỗi", message: "Mật khẩu xác nhận không khớp.")
            return
        }
        
        do {
            try store.resetPassword(email: emailAddress ?? "", newPassword: newPass)
            showAlert(title: "Thành công", message: "Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay bây giờ.") {
                self.handleBackNavigation()
            }
        } catch {
            showAlert(title: "Không thể đổi mật khẩu", message: error.localizedDescription)
        }
    }
}

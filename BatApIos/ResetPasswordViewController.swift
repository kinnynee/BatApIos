import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordEyeButton: UIButton!
    @IBOutlet weak var confirmPasswordEyeButton: UIButton!
    
    // Quản lý trạng thái ẩn/hiện của 2 ô mật khẩu riêng biệt
    var isNewPassVisible = false
    var isConfirmPassVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Mặc định ẩn mật khẩu
        newPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }

    // MARK: - IBActions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // Nút mắt của ô Mật khẩu mới
    @IBAction func toggleNewPasswordVisibility(_ sender: UIButton) {
        isNewPassVisible.toggle()
        newPasswordTextField.isSecureTextEntry = !isNewPassVisible
        let icon = isNewPassVisible ? "eye" : "eye.slash"
        newPasswordEyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    // Nút mắt của ô Xác nhận mật khẩu
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
        
        // Kiểm tra độ mạnh mật khẩu
        if newPass.count < 8 {
            showAlert(title: "Mật khẩu yếu", message: "Mật khẩu phải có ít nhất 8 ký tự.")
            return
        }
        
        // Kiểm tra khớp nhau
        if newPass != confirmPass {
            showAlert(title: "Lỗi", message: "Mật khẩu xác nhận không khớp.")
            return
        }
        
        showAlert(title: "Thành công", message: "Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay bây giờ.") {
            // Đóng tất cả các màn hình để về lại màn hình Login ban đầu
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

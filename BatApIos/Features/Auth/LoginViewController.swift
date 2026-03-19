import UIKit

class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    
    var isPasswordVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        passwordTextField.isSecureTextEntry = true
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }

    // MARK: - IBActions
    
    // 1. Nút ẩn/hiện mật khẩu
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let icon = isPasswordVisible ? "eye" : "eye.slash"
        eyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    // 2. Nút Đăng nhập (Màu Xanh Mint)
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập đầy đủ Email và Mật khẩu.")
            return
        }
        
        if !isValidEmail(email) {
            showAlert(title: "Lỗi", message: "Định dạng Email không hợp lệ.")
            return
        }
        
        showAlert(title: "Thành công", message: "Đăng nhập thành công!")
    }
    
    // 3. Nút Đăng ký (Màu Xanh Lá) - Gọi màn hình Register
    @IBAction func goToRegisterScreen(_ sender: UIButton) {
        // Khởi tạo file Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Tìm màn hình có ID là "RegisterVC"
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as? RegisterViewController {
            
            // Cài đặt kiểu hiển thị là tràn viền (Full Screen)
            registerVC.modalPresentationStyle = .fullScreen
            
            // Hiển thị màn hình lên
            self.present(registerVC, animated: true, completion: nil)
        } else {
            print("Lỗi: Không tìm thấy màn hình có ID là RegisterVC")
        }
    }
}

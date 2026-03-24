import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    
    var isPasswordVisible = false
    private let store = AppMockStore.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        passwordTextField.isSecureTextEntry = true
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }

    
    @IBAction func togglePasswordVisibility(_ sender: UIButton) {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        let icon = isPasswordVisible ? "eye" : "eye.slash"
        eyeButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
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

        do {
            let user = try store.login(email: email, password: password)
            showAlert(title: "Thành công", message: "Đăng nhập thành công!") {
                self.routeToNextScreen(for: user)
            }
        } catch {
            showAlert(title: "Đăng nhập thất bại", message: error.localizedDescription)
        }
    }
    
    @IBAction func goToRegisterScreen(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as? RegisterViewController {
            
            registerVC.modalPresentationStyle = .fullScreen
            
            self.present(registerVC, animated: true, completion: nil)
        } else {
            print("Lỗi: Không tìm thấy màn hình có ID là RegisterVC")
        }
    }

    private func routeToNextScreen(for user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let targetIdentifier: String

        switch user.role {
        case .admin:
            targetIdentifier = "AdminDashboardVC"
        case .staff:
            targetIdentifier = "StaffCheckInVC"
        case .user:
            targetIdentifier = "MainTabBarVC"
        }

        guard let nextViewController = storyboard.instantiateViewController(withIdentifier: targetIdentifier) as UIViewController? else {
            return
        }

        nextViewController.modalPresentationStyle = .fullScreen
        present(nextViewController, animated: true)
    }
}
//up

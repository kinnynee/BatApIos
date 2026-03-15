import UIKit

// Mở rộng chức năng cho tất cả các View Controller
extension UIViewController {
    
    // Hàm hiển thị thông báo (Alert) chuẩn mực
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Đã hiểu", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        DispatchQueue.main.async {
            let presenter = self.topMostPresentedViewController()
            guard !(presenter is UIAlertController) else { return }
            presenter.present(alert, animated: true)
        }
    }
    
    // Hàm dùng Biểu thức chính quy (Regex) để kiểm tra định dạng Email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func topMostPresentedViewController() -> UIViewController {
        var presenter = self
        while let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }
        return presenter
    }
}

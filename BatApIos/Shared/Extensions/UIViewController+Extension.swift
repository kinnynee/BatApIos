import UIKit

extension UIViewController {
    
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
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    func dismissKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingFromTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func endEditingFromTap() {
        view.endEditing(true)
    }

    private func topMostPresentedViewController() -> UIViewController {
        var presenter = self
        while let presentedViewController = presenter.presentedViewController {
            presenter = presentedViewController
        }
        return presenter
    }
}

import UIKit

final class ChangePasswordViewController: UIViewController {

    @IBOutlet private weak var currentPasswordTextField: UITextField!
    @IBOutlet private weak var newPasswordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    private let store = AppMockStore.shared
    private let authService = FirebaseAuthService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        [currentPasswordTextField, newPasswordTextField, confirmPasswordTextField].forEach {
            $0?.isSecureTextEntry = true
        }
        dismissKeyboardWhenTappedAround()
    }

    @IBAction private func backButtonTapped(_ sender: UIButton) {
        handleBackNavigation()
    }

    @IBAction private func updatePasswordTapped(_ sender: UIButton) {
        guard
            let currentPassword = currentPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !currentPassword.isEmpty,
            !newPassword.isEmpty,
            !confirmPassword.isEmpty
        else {
            showAlert(title: "Thiếu thông tin", message: "Vui lòng nhập đầy đủ mật khẩu hiện tại và mật khẩu mới.")
            return
        }

        guard newPassword.count >= 8 else {
            showAlert(title: "Mật khẩu yếu", message: "Mật khẩu mới phải có ít nhất 8 ký tự.")
            return
        }

        guard newPassword != currentPassword else {
            showAlert(title: "Không hợp lệ", message: "Mật khẩu mới phải khác mật khẩu hiện tại.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert(title: "Không khớp", message: "Mật khẩu xác nhận không khớp.")
            return
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                try await authService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                store.updateCurrentUserPassword(newPassword)

                await MainActor.run {
                    self.showAlert(title: "Thành công", message: "Mật khẩu đã được cập nhật.") {
                        self.handleBackNavigation()
                    }
                }
            } catch {
                await MainActor.run {
                    self.showAlert(title: "Không thể đổi mật khẩu", message: error.localizedDescription)
                }
            }
        }
    }
}

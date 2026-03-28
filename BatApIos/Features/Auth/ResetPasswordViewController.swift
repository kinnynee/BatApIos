import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var newPasswordTextField: UITextField?
    @IBOutlet weak var confirmPasswordTextField: UITextField?

    @IBOutlet weak var newPasswordEyeButton: UIButton?
    @IBOutlet weak var confirmPasswordEyeButton: UIButton?

    var isNewPassVisible = false
    var isConfirmPassVisible = false
    var emailAddress: String?
    private let store = AppMockStore.shared

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let contentStackView = UIStackView()
    private let newPasswordContainer = UIView()
    private let confirmPasswordContainer = UIView()
    private let fallbackNewPasswordTextField = UITextField()
    private let fallbackConfirmPasswordTextField = UITextField()
    private let fallbackNewPasswordEyeButton = UIButton(type: .system)
    private let fallbackConfirmPasswordEyeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func toggleNewPasswordVisibility(_ sender: UIButton) {
        isNewPassVisible.toggle()
        activeNewPasswordTextField?.isSecureTextEntry = !isNewPassVisible
        activeNewPasswordEyeButton?.setImage(UIImage(systemName: isNewPassVisible ? "eye" : "eye.slash"), for: .normal)
    }

    @IBAction func toggleConfirmPasswordVisibility(_ sender: UIButton) {
        isConfirmPassVisible.toggle()
        activeConfirmPasswordTextField?.isSecureTextEntry = !isConfirmPassVisible
        activeConfirmPasswordEyeButton?.setImage(UIImage(systemName: isConfirmPassVisible ? "eye" : "eye.slash"), for: .normal)
    }

    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        guard let newPass = activeNewPasswordTextField?.text, !newPass.isEmpty,
              let confirmPass = activeConfirmPasswordTextField?.text, !confirmPass.isEmpty else {
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
                self.dismiss(animated: true)
            }
        } catch {
            showAlert(title: "Không thể đổi mật khẩu", message: error.localizedDescription)
        }
    }
}

private extension ResetPasswordViewController {
    var activeNewPasswordTextField: UITextField? {
        newPasswordTextField ?? fallbackNewPasswordTextField
    }

    var activeConfirmPasswordTextField: UITextField? {
        confirmPasswordTextField ?? fallbackConfirmPasswordTextField
    }

    var activeNewPasswordEyeButton: UIButton? {
        newPasswordEyeButton ?? fallbackNewPasswordEyeButton
    }

    var activeConfirmPasswordEyeButton: UIButton? {
        confirmPasswordEyeButton ?? fallbackConfirmPasswordEyeButton
    }

    func configureUI() {
        if newPasswordTextField == nil || confirmPasswordTextField == nil {
            buildFallbackUI()
        }

        activeNewPasswordTextField?.isSecureTextEntry = true
        activeConfirmPasswordTextField?.isSecureTextEntry = true
        activeNewPasswordEyeButton?.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        activeConfirmPasswordEyeButton?.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        dismissKeyboardWhenTappedAround()
    }

    func buildFallbackUI() {
        view.backgroundColor = .systemBackground

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(handleBackButtonTap), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = "Đặt lại mật khẩu"

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Thiết lập mật khẩu mới cho \(emailAddress ?? "tài khoản của bạn")."

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 18

        configurePasswordField(
            container: newPasswordContainer,
            textField: fallbackNewPasswordTextField,
            eyeButton: fallbackNewPasswordEyeButton,
            placeholder: "Mật khẩu mới",
            selector: #selector(handleNewPasswordEyeTap)
        )
        configurePasswordField(
            container: confirmPasswordContainer,
            textField: fallbackConfirmPasswordTextField,
            eyeButton: fallbackConfirmPasswordEyeButton,
            placeholder: "Xác nhận mật khẩu mới",
            selector: #selector(handleConfirmPasswordEyeTap)
        )

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Cập nhật mật khẩu", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
        resetButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        resetButton.layer.cornerRadius = 16
        resetButton.addTarget(self, action: #selector(handleResetButtonTap), for: .touchUpInside)

        [backButton, titleLabel, subtitleLabel, contentStackView, resetButton].forEach {
            view.addSubview($0)
        }
        [newPasswordContainer, confirmPasswordContainer].forEach {
            contentStackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            contentStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            contentStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            resetButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            resetButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func configurePasswordField(
        container: UIView,
        textField: UITextField,
        eyeButton: UIButton,
        placeholder: String,
        selector: Selector
    ) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.95, alpha: 1.0)
        container.layer.cornerRadius = 18

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.textContentType = .newPassword
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.tintColor = .secondaryLabel
        eyeButton.addTarget(self, action: selector, for: .touchUpInside)

        container.addSubview(textField)
        container.addSubview(eyeButton)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 56),

            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: container.topAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            eyeButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 12),
            eyeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            eyeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            eyeButton.widthAnchor.constraint(equalToConstant: 24),

            textField.trailingAnchor.constraint(equalTo: eyeButton.leadingAnchor, constant: -12)
        ])
    }

    @objc func handleBackButtonTap() {
        dismiss(animated: true)
    }

    @objc func handleNewPasswordEyeTap() {
        toggleNewPasswordVisibility(fallbackNewPasswordEyeButton)
    }

    @objc func handleConfirmPasswordEyeTap() {
        toggleConfirmPasswordVisibility(fallbackConfirmPasswordEyeButton)
    }

    @objc func handleResetButtonTap() {
        resetPasswordTapped(resetButton)
    }
}

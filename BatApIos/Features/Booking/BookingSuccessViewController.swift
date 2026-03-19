import UIKit

final class BookingSuccessViewController: UIViewController {

    var bookingCode: String = "BK-882941"

    private let bookingIdLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .systemBackground

        let headerLabel = UILabel()
        headerLabel.text = "Booking Confirmed"
        headerLabel.font = .boldSystemFont(ofSize: 22)
        headerLabel.textColor = UIColor(red: 0.039, green: 0.416, blue: 0.114, alpha: 1)
        headerLabel.textAlignment = .center

        let successIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        successIcon.tintColor = UIColor(red: 0.039, green: 0.416, blue: 0.114, alpha: 1)
        successIcon.contentMode = .scaleAspectFit

        let successLabel = UILabel()
        successLabel.text = "Đặt sân thành công!"
        successLabel.font = .boldSystemFont(ofSize: 28)
        successLabel.textAlignment = .center

        bookingIdLabel.text = "Mã đặt sân: #\(bookingCode)"
        bookingIdLabel.font = .systemFont(ofSize: 15, weight: .medium)
        bookingIdLabel.textColor = .secondaryLabel
        bookingIdLabel.textAlignment = .center

        let qrContainer = UIView()
        qrContainer.backgroundColor = UIColor.secondarySystemBackground
        qrContainer.layer.cornerRadius = 20

        let qrImageView = UIImageView(image: UIImage(systemName: "qrcode.viewfinder"))
        qrImageView.tintColor = .systemGray
        qrImageView.contentMode = .scaleAspectFit

        let historyButton = UIButton(type: .system)
        historyButton.configuration = makePrimaryButtonConfiguration(title: "Xem lịch của tôi")
        historyButton.addTarget(self, action: #selector(viewMyBookingsTapped), for: .touchUpInside)

        let homeButton = UIButton(type: .system)
        homeButton.configuration = makeSecondaryButtonConfiguration(title: "Quay về trang chủ")
        homeButton.addTarget(self, action: #selector(goHomeTapped), for: .touchUpInside)

        [headerLabel, successIcon, successLabel, bookingIdLabel, qrContainer, historyButton, homeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        qrContainer.addSubview(qrImageView)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            successIcon.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 32),
            successIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successIcon.widthAnchor.constraint(equalToConstant: 80),
            successIcon.heightAnchor.constraint(equalToConstant: 80),

            successLabel.topAnchor.constraint(equalTo: successIcon.bottomAnchor, constant: 24),
            successLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            successLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),

            bookingIdLabel.topAnchor.constraint(equalTo: successLabel.bottomAnchor, constant: 12),
            bookingIdLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            bookingIdLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),

            qrContainer.topAnchor.constraint(equalTo: bookingIdLabel.bottomAnchor, constant: 36),
            qrContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrContainer.widthAnchor.constraint(equalToConstant: 300),
            qrContainer.heightAnchor.constraint(equalToConstant: 200),

            qrImageView.centerXAnchor.constraint(equalTo: qrContainer.centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: qrContainer.centerYAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 100),
            qrImageView.heightAnchor.constraint(equalToConstant: 100),

            historyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            historyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            historyButton.bottomAnchor.constraint(equalTo: homeButton.topAnchor, constant: -12),
            historyButton.heightAnchor.constraint(equalToConstant: 50),

            homeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            homeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            homeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            homeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func makePrimaryButtonConfiguration(title: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = UIColor(red: 0.039, green: 0.416, blue: 0.114, alpha: 1)
        configuration.baseForegroundColor = .white
        return configuration
    }

    private func makeSecondaryButtonConfiguration(title: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.gray()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseForegroundColor = .label
        return configuration
    }

    @objc private func viewMyBookingsTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let paymentViewController = storyboard.instantiateViewController(withIdentifier: "PaymentVC")
        navigationController?.pushViewController(paymentViewController, animated: true)
    }

    @objc private func goHomeTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}

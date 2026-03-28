import CoreImage.CIFilterBuiltins
import UIKit

final class BookingDetailViewController: UIViewController {

    var booking: BookingRecord?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let qrContainerView = UIView()
    private let qrImageView = UIImageView()
    private let bookingCodeLabel = UILabel()
    private let openCheckInButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chi tiết booking"
        view.backgroundColor = .systemGroupedBackground
        configureLayout()
        populateData()
    }
}

private extension BookingDetailViewController {
    func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        qrContainerView.translatesAutoresizingMaskIntoConstraints = false
        qrImageView.translatesAutoresizingMaskIntoConstraints = false
        bookingCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        openCheckInButton.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 16

        qrContainerView.backgroundColor = .secondarySystemBackground
        qrContainerView.layer.cornerRadius = 24

        qrImageView.contentMode = .scaleAspectFit
        qrImageView.tintColor = .label

        bookingCodeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        bookingCodeLabel.textAlignment = .center
        bookingCodeLabel.textColor = .secondaryLabel

        var configuration = UIButton.Configuration.filled()
        configuration.title = "Mở check-in demo"
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)
        configuration.baseForegroundColor = .white
        openCheckInButton.configuration = configuration
        openCheckInButton.addTarget(self, action: #selector(openCheckInDemoTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        contentView.addSubview(qrContainerView)
        contentView.addSubview(bookingCodeLabel)
        contentView.addSubview(openCheckInButton)
        qrContainerView.addSubview(qrImageView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            qrContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            qrContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            qrContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            qrContainerView.heightAnchor.constraint(equalToConstant: 240),

            qrImageView.centerXAnchor.constraint(equalTo: qrContainerView.centerXAnchor),
            qrImageView.centerYAnchor.constraint(equalTo: qrContainerView.centerYAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 150),
            qrImageView.heightAnchor.constraint(equalToConstant: 150),

            bookingCodeLabel.topAnchor.constraint(equalTo: qrContainerView.bottomAnchor, constant: 16),
            bookingCodeLabel.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor, constant: 16),
            bookingCodeLabel.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor, constant: -16),

            openCheckInButton.topAnchor.constraint(equalTo: bookingCodeLabel.bottomAnchor, constant: 16),
            openCheckInButton.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor),
            openCheckInButton.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor),
            openCheckInButton.heightAnchor.constraint(equalToConstant: 52),

            stackView.topAnchor.constraint(equalTo: openCheckInButton.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: qrContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: qrContainerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    func populateData() {
        guard let booking else { return }

        bookingCodeLabel.text = "Mã check-in: #\(booking.id)"
        qrImageView.image = generateQRCode(from: booking.id)

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "vi_VN")
        currencyFormatter.maximumFractionDigits = 0

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateFormatter.dateFormat = "EEEE, dd/MM/yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "vi_VN")
        timeFormatter.dateFormat = "HH:mm"

        let detailItems: [(String, String)] = [
            ("Sân", booking.courtName),
            ("Số sân", booking.courtNumber.map { "Sân \($0)" } ?? "Đang cập nhật"),
            ("Loại sân", booking.courtTypeName ?? "Đang cập nhật"),
            ("Ngày chơi", dateFormatter.string(from: booking.bookingDate)),
            ("Khung giờ", "\(timeFormatter.string(from: booking.startTime)) - \(timeFormatter.string(from: booking.endTime))"),
            ("Trạng thái", statusText(for: booking.status)),
            ("Thanh toán", booking.paymentMethodName ?? "Chưa thanh toán"),
            ("Voucher", booking.voucherCode ?? "Không áp dụng"),
            ("Tổng tiền", currencyFormatter.string(from: NSNumber(value: booking.totalPrice)) ?? "0 đ")
        ]

        detailItems.forEach { title, value in
            stackView.addArrangedSubview(makeInfoCard(title: title, value: value))
        }
    }

    func makeInfoCard(title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 18
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.text = value

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])

        return container
    }

    func statusText(for status: BookingStatus) -> String {
        switch status {
        case .pending:
            return "Chờ thanh toán"
        case .partiallyPaid:
            return "Đã cọc"
        case .fullyPaid:
            return "Đã thanh toán"
        case .active:
            return "Đang diễn ra"
        case .cancelled:
            return "Đã hủy"
        }
    }

    func generateQRCode(from code: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(code.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    @objc func openCheckInDemoTapped() {
        guard let booking else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let checkInViewController = storyboard.instantiateViewController(withIdentifier: "StaffCheckInVC") as? StaffCheckInViewController else {
            return
        }
        checkInViewController.prefilledBookingCode = booking.id
        navigationController?.pushViewController(checkInViewController, animated: true)
    }
}

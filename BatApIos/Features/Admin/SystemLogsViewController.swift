import UIKit

final class SystemLogsViewController: StoryboardScreenViewController, UITextFieldDelegate {
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchTextField: UITextField!

    @IBOutlet private weak var firstCardView: UIView!
    @IBOutlet private weak var firstCardTitleLabel: UILabel!
    @IBOutlet private weak var firstCardSubtitleLabel: UILabel!
    @IBOutlet private weak var firstCardBadgeView: UIView!
    @IBOutlet private weak var firstCardBadgeLabel: UILabel!
    @IBOutlet private weak var firstCardTimeLabel: UILabel!
    @IBOutlet private weak var firstCardDetailButton: UIButton!
    @IBOutlet private weak var firstCardIconImageView: UIImageView!

    @IBOutlet private weak var secondCardView: UIView!
    @IBOutlet private weak var secondCardTitleLabel: UILabel!
    @IBOutlet private weak var secondCardSubtitleLabel: UILabel!
    @IBOutlet private weak var secondCardDescriptionLabel: UILabel!
    @IBOutlet private weak var secondCardBadgeView: UIView!
    @IBOutlet private weak var secondCardBadgeLabel: UILabel!
    @IBOutlet private weak var secondCardTimeLabel: UILabel!
    @IBOutlet private weak var secondCardDetailButton: UIButton!
    @IBOutlet private weak var secondCardIconImageView: UIImageView!

    @IBOutlet private weak var thirdCardView: UIView!
    @IBOutlet private weak var thirdCardTitleLabel: UILabel!
    @IBOutlet private weak var thirdCardSubtitleLabel: UILabel!
    @IBOutlet private weak var thirdCardTimeLabel: UILabel!
    @IBOutlet private weak var thirdCardDetailButton: UIButton!
    @IBOutlet private weak var thirdCardIconImageView: UIImageView!

    private let store = AppMockStore.shared
    private let systemLogStore = SystemLogStore.shared

    private enum SourceFilter: String, CaseIterable {
        case all = "Tất cả"
        case backend = "Backend"
        case mock = "Mock"
    }

    private struct DisplayLog {
        let title: String
        let subtitle: String
        let detail: String
        let time: String
        let source: String
        let createdAt: Date
    }

    private var selectedFilter: SourceFilter = .all
    private var searchKeyword: String = ""
    private var currentLogs: [DisplayLog] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStaticUI()
        reloadLogs()
    }

    private func configureStaticUI() {
        title = "Nhật ký hệ thống"
        navigationItem.largeTitleDisplayMode = .never

        titleLabel?.text = "Nhật ký hệ thống"
        searchTextField?.delegate = self
        searchTextField?.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        filterButton?.setTitle(selectedFilter.rawValue, for: .normal)
        backButton?.setTitle(nil, for: .normal)
        backButton?.tintColor = .systemGreen
        backButton?.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        backButton?.layer.cornerRadius = 20
        backButton?.layer.masksToBounds = true
        backButton?.accessibilityLabel = "Quay về"
        backButton?.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
        filterButton?.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        firstCardDetailButton?.addTarget(self, action: #selector(firstDetailTapped(_:)), for: .touchUpInside)
        secondCardDetailButton?.addTarget(self, action: #selector(secondDetailTapped(_:)), for: .touchUpInside)
        thirdCardDetailButton?.addTarget(self, action: #selector(thirdDetailTapped(_:)), for: .touchUpInside)

        configureCardTap(firstCardView, index: 0)
        configureCardTap(secondCardView, index: 1)
        configureCardTap(thirdCardView, index: 2)

        [firstCardView, secondCardView, thirdCardView].forEach {
            $0?.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }

    private func reloadLogs() {
        let backendLogs = systemLogStore.allEntries().map {
            DisplayLog(
                title: $0.title,
                subtitle: "Nguồn: \($0.source.uppercased())",
                detail: $0.message,
                time: formattedTime($0.createdAt),
                source: $0.source,
                createdAt: $0.createdAt
            )
        }

        let mockLogs = store.systemLogs().map {
            DisplayLog(
                title: $0.title,
                subtitle: "Nguồn: MOCK",
                detail: $0.message,
                time: formattedTime($0.createdAt),
                source: "mock",
                createdAt: $0.createdAt
            )
        }

        let combinedLogs = (backendLogs + mockLogs)
            .filter { log in
                switch selectedFilter {
                case .all:
                    return true
                case .backend:
                    return log.source != "mock"
                case .mock:
                    return log.source == "mock"
                }
            }
            .filter { log in
                guard searchKeyword.isEmpty == false else { return true }
                let keyword = normalized(searchKeyword)
                return normalized(log.title).contains(keyword) ||
                    normalized(log.subtitle).contains(keyword) ||
                    normalized(log.detail).contains(keyword)
            }

        currentLogs = Array(combinedLogs.prefix(3))
        renderCards()
    }

    private func renderCards() {
        renderCard(
            container: firstCardView,
            titleLabel: firstCardTitleLabel,
            subtitleLabel: firstCardSubtitleLabel,
            detailLabel: nil,
            badgeView: firstCardBadgeView,
            badgeLabel: firstCardBadgeLabel,
            timeLabel: firstCardTimeLabel,
            detailButton: firstCardDetailButton,
            iconImageView: firstCardIconImageView,
            log: currentLogs[safe: 0]
        )

        renderCard(
            container: secondCardView,
            titleLabel: secondCardTitleLabel,
            subtitleLabel: secondCardSubtitleLabel,
            detailLabel: secondCardDescriptionLabel,
            badgeView: secondCardBadgeView,
            badgeLabel: secondCardBadgeLabel,
            timeLabel: secondCardTimeLabel,
            detailButton: secondCardDetailButton,
            iconImageView: secondCardIconImageView,
            log: currentLogs[safe: 1]
        )

        renderCard(
            container: thirdCardView,
            titleLabel: thirdCardTitleLabel,
            subtitleLabel: thirdCardSubtitleLabel,
            detailLabel: nil,
            badgeView: nil,
            badgeLabel: nil,
            timeLabel: thirdCardTimeLabel,
            detailButton: thirdCardDetailButton,
            iconImageView: thirdCardIconImageView,
            log: currentLogs[safe: 2]
        )
    }

    private func renderCard(
        container: UIView?,
        titleLabel: UILabel?,
        subtitleLabel: UILabel?,
        detailLabel: UILabel?,
        badgeView: UIView?,
        badgeLabel: UILabel?,
        timeLabel: UILabel?,
        detailButton: UIButton?,
        iconImageView: UIImageView?,
        log: DisplayLog?
    ) {
        guard let container else { return }

        guard let log else {
            container.isHidden = true
            return
        }

        container.isHidden = false
        titleLabel?.text = log.title
        subtitleLabel?.text = log.subtitle
        detailLabel?.text = log.detail
        detailLabel?.isHidden = detailLabel == nil ? true : false
        timeLabel?.text = log.time

        let badgeText = badgeText(for: log.source)
        badgeLabel?.text = badgeText.text
        badgeLabel?.textColor = badgeText.foregroundColor
        badgeView?.backgroundColor = badgeText.backgroundColor

        iconImageView?.image = UIImage(systemName: iconName(for: log.source))
        iconImageView?.tintColor = badgeText.foregroundColor

        detailButton?.isHidden = false
    }

    private func badgeText(for source: String) -> (text: String, foregroundColor: UIColor, backgroundColor: UIColor) {
        if source == "mock" {
            return ("MOCK", .systemOrange, UIColor.systemOrange.withAlphaComponent(0.14))
        }

        if source == "admin" {
            return ("ADMIN", .systemBlue, UIColor.systemBlue.withAlphaComponent(0.14))
        }

        if source == "payment" {
            return ("PAYMENT", .systemGreen, UIColor.systemGreen.withAlphaComponent(0.14))
        }

        if source == "booking" {
            return ("BOOKING", .systemMint, UIColor.systemMint.withAlphaComponent(0.14))
        }

        return ("SYSTEM", .systemIndigo, UIColor.systemIndigo.withAlphaComponent(0.14))
    }

    private func iconName(for source: String) -> String {
        switch source {
        case "admin":
            return "person.crop.circle.badge.checkmark"
        case "payment":
            return "creditcard.fill"
        case "booking":
            return "calendar.badge.plus"
        case "mock":
            return "shippingbox.fill"
        default:
            return "list.bullet.clipboard.fill"
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date()).capitalized
    }

    private func normalized(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "vi_VN"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @objc private func searchTextChanged() {
        searchKeyword = searchTextField?.text ?? ""
        reloadLogs()
    }

    @IBAction private func backTapped(_ sender: UIButton) {
        handleBackNavigation()
    }

    @IBAction private func filterTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Lọc nhật ký", message: nil, preferredStyle: .actionSheet)
        SourceFilter.allCases.forEach { filter in
            alert.addAction(UIAlertAction(title: filter.rawValue, style: .default, handler: { [weak self] _ in
                self?.selectedFilter = filter
                self?.filterButton?.setTitle(filter.rawValue, for: .normal)
                self?.reloadLogs()
            }))
        }
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }

        present(alert, animated: true)
    }

    @IBAction private func firstDetailTapped(_ sender: UIButton) {
        presentDetails(for: 0)
    }

    @IBAction private func secondDetailTapped(_ sender: UIButton) {
        presentDetails(for: 1)
    }

    @IBAction private func thirdDetailTapped(_ sender: UIButton) {
        presentDetails(for: 2)
    }

    private func presentDetails(for index: Int) {
        guard currentLogs.indices.contains(index) else { return }
        let log = currentLogs[index]
        let alert = UIAlertController(
            title: detailTitle(for: log),
            message: detailMessage(for: log),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Đóng", style: .default))
        present(alert, animated: true)
    }

    private func detailTitle(for log: DisplayLog) -> String {
        switch normalized(log.title) {
        case let value where value.contains("dang nhap"):
            return "Chi tiết đăng nhập"
        case let value where value.contains("tao booking"):
            return "Chi tiết tạo booking"
        case let value where value.contains("thanh toan"):
            return "Chi tiết thanh toán"
        case let value where value.contains("huy"):
            return "Chi tiết hủy thao tác"
        case let value where value.contains("check-in"), let value where value.contains("check in"):
            return "Chi tiết check-in"
        default:
            return "Chi tiết nhật ký"
        }
    }

    private func detailMessage(for log: DisplayLog) -> String {
        let actor = actorText(from: log.detail, fallback: log.source.uppercased())
        let action = actionText(for: log)
        let impact = impactText(for: log)
        let timestamp = absoluteFormattedTime(log.createdAt)

        return [
            "Loại sự kiện: \(log.title)",
            "Tác nhân: \(actor)",
            "Hành động: \(action)",
            "Ảnh hưởng: \(impact)",
            "Thời điểm: \(timestamp)",
            "",
            "Thông điệp gốc:",
            log.detail
        ].joined(separator: "\n")
    }

    private func actorText(from message: String, fallback: String) -> String {
        if let actorRange = message.range(of: "Admin ", options: .caseInsensitive) {
            let actor = String(message[actorRange.lowerBound...]).split(separator: " ").prefix(2).joined(separator: " ")
            return actor
        }

        if let firstWord = message.split(separator: " ").first, firstWord.contains("@") {
            return String(firstWord)
        }

        if message.localizedCaseInsensitiveContains("Khách") {
            return "Khách hàng"
        }

        if message.localizedCaseInsensitiveContains("Admin") {
            return "Quản trị viên"
        }

        return fallback
    }

    private func actionText(for log: DisplayLog) -> String {
        let value = normalized(log.title + " " + log.detail)
        if value.contains("dang nhap") {
            return "Đăng nhập vào hệ thống"
        }
        if value.contains("tao booking") {
            return "Tạo mới một booking sân"
        }
        if value.contains("thanh toan") {
            return "Xác nhận hoặc hoàn tất thanh toán"
        }
        if value.contains("huy") {
            return "Hủy booking hoặc giao dịch liên quan"
        }
        if value.contains("checkin") || value.contains("check-in") {
            return "Xác nhận khách đã đến sân"
        }
        return "Ghi nhận một thao tác hệ thống"
    }

    private func impactText(for log: DisplayLog) -> String {
        let value = normalized(log.title + " " + log.detail)
        if value.contains("booking") && value.contains("huy") {
            return "Booking và trạng thái thanh toán được chuyển sang hủy"
        }
        if value.contains("thanh toan") {
            return "Trạng thái thanh toán của booking được cập nhật"
        }
        if value.contains("checkin") || value.contains("check-in") {
            return "Booking được chuyển sang trạng thái đã check-in"
        }
        if value.contains("dang nhap") {
            return "Phiên truy cập hệ thống được ghi nhận"
        }
        if value.contains("tao booking") {
            return "Một lịch đặt sân mới đã được tạo"
        }
        return "Nhật ký được lưu để phục vụ theo dõi và kiểm tra"
    }

    private func absoluteFormattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "HH:mm - dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private func configureCardTap(_ view: UIView?, index: Int) {
        guard let view else { return }
        view.tag = index
        view.isUserInteractionEnabled = true

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
    }

    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        presentDetails(for: view.tag)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

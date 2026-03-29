import UIKit

final class NewCourtBookingViewController: UIViewController {
    var preselectedCourtID: String?
    var preselectedCourtName: String?

    private let store = AppMockStore.shared
    private let bookingsService = BackendBookingsService.shared
    private let systemLogStore = SystemLogStore.shared
    private let courtsService = BackendCourtsService.shared
    private let vouchersService = BackendVouchersService.shared
    private let calendar = Calendar.current
    private var currentLanguage: AppLanguage { AppLocalization.currentLanguage }

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let courtSectionStack = UIStackView()
    private let selectedDateLabel = UILabel()
    private let voucherTextField = UITextField()
    private let totalAmountLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private let priceAmountLabel = UILabel()
    private let voucherAmountLabel = UILabel()

    private var dateButtons: [UIButton] = []
    private var timeButtons: [UIButton] = []
    private var courtButtons: [UIButton] = []

    private lazy var availableDates = makeAvailableDates()
    private let availableTimes = [
        "06:00",
        "07:30",
        "09:00",
        "10:00",
        "11:00",
        "18:00",
        "19:00",
        "20:00"
    ]
    private var courts: [BackendCourtOption] = []

    private var selectedDateIndex = 1 {
        didSet { updateDateSelectionUI() }
    }
    private var selectedTimeIndex = 3 {
        didSet { updateTimeSelectionUI() }
    }
    private var selectedCourtIndex = 1 {
        didSet { updateCourtSelectionUI() }
    }
    private var isVoucherApplied = false {
        didSet { updateSummary() }
    }
    private var appliedVoucherCode: String?
    private var appliedDiscountAmount: Double = 0 {
        didSet { updateSummary() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureScreen()
        buildLayout()
        updateDateSelectionUI()
        updateTimeSelectionUI()
        updateCourtSelectionUI()
        updateSummary()
        loadCourts()
    }

    private func configureScreen() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1)
        navigationItem.hidesBackButton = true
    }

    private func buildLayout() {
        let header = makeHeader()
        let dateSection = makeDateSection()
        let timeSection = makeTimeSection()
        let courtSection = makeCourtSection()
        let voucherSection = makeVoucherSection()
        let summarySection = makeSummarySection()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24

        [header, scrollView, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        view.addSubview(header)
        view.addSubview(scrollView)
        view.addSubview(confirmButton)
        scrollView.addSubview(contentStack)

        [dateSection, timeSection, courtSection, voucherSection, summarySection].forEach {
            contentStack.addArrangedSubview($0)
        }

        confirmButton.configuration = makePrimaryButtonConfiguration(title: text(.confirmBooking))
        confirmButton.addTarget(self, action: #selector(confirmBookingTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            confirmButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 56),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func makeHeader() -> UIView {
        let container = UIView()

        let backButton = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "chevron.backward")
        backButton.configuration = configuration
        backButton.tintColor = .label
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = text(.bookCourtTitle)
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(backButton)
        container.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 60),
            backButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    private func makeDateSection() -> UIView {
        selectedDateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        selectedDateLabel.textColor = .systemMint

        let section = makeSectionContainer(title: text(.selectDate), trailingView: selectedDateLabel)
        let stack = makeHorizontalButtonStack()

        dateButtons = availableDates.enumerated().map { index, date in
            let button = makeSelectableButton(title: shortDateTitle(for: date)) { [weak self] in
                self?.selectedDateIndex = index
            }
            stack.addArrangedSubview(button)
            return button
        }

        section.addArrangedSubview(stack)
        return section
    }

    private func makeTimeSection() -> UIView {
        let section = makeSectionContainer(title: text(.selectTime))

        let firstRow = UIStackView()
        firstRow.axis = .horizontal
        firstRow.spacing = 12
        firstRow.distribution = .fillEqually

        let secondRow = UIStackView()
        secondRow.axis = .horizontal
        secondRow.spacing = 12
        secondRow.distribution = .fillEqually

        timeButtons = availableTimes.enumerated().map { index, title in
            let button = makeSelectableButton(title: title) { [weak self] in
                self?.selectedTimeIndex = index
            }
            if index < 3 {
                firstRow.addArrangedSubview(button)
            } else {
                secondRow.addArrangedSubview(button)
            }
            return button
        }

        section.addArrangedSubview(firstRow)
        section.addArrangedSubview(secondRow)
        return section
    }

    private func makeCourtSection() -> UIView {
        courtSectionStack.axis = .vertical
        courtSectionStack.spacing = 12
        courtSectionStack.arrangedSubviews.forEach { view in
            courtSectionStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let section = makeSectionContainer(title: text(.selectCourtType))
        section.addArrangedSubview(courtSectionStack)
        renderCourtOptions()
        return section
    }

    private func makeVoucherSection() -> UIView {
        let section = makeSectionContainer(title: text(.voucherCode))

        voucherTextField.borderStyle = .none
        voucherTextField.placeholder = text(.enterVoucherCode)
        voucherTextField.font = .systemFont(ofSize: 15)
        voucherTextField.autocapitalizationType = .allCharacters

        let textContainer = UIView()
        textContainer.backgroundColor = .white
        textContainer.layer.cornerRadius = 16
        textContainer.layer.borderWidth = 1
        textContainer.layer.borderColor = UIColor.systemGray5.cgColor
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        voucherTextField.translatesAutoresizingMaskIntoConstraints = false
        textContainer.addSubview(voucherTextField)

        let applyButton = UIButton(type: .system)
        applyButton.configuration = makeSecondaryButtonConfiguration(title: text(.apply))
        applyButton.addTarget(self, action: #selector(applyVoucherTapped), for: .touchUpInside)

        let row = UIStackView(arrangedSubviews: [textContainer, applyButton])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .fill

        NSLayoutConstraint.activate([
            textContainer.heightAnchor.constraint(equalToConstant: 52),
            voucherTextField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 16),
            voucherTextField.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -16),
            voucherTextField.topAnchor.constraint(equalTo: textContainer.topAnchor),
            voucherTextField.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor),
            applyButton.widthAnchor.constraint(equalToConstant: 100)
        ])

        section.addArrangedSubview(row)
        return section
    }

    private func makeSummarySection() -> UIView {
        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 12
        card.backgroundColor = .white
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor

        let title = UILabel()
        title.text = text(.paymentSummary)
        title.font = .boldSystemFont(ofSize: 16)

        let priceRow = makeSummaryRow(title: summaryPriceTitle, value: currencyText(selectedCourtPrice * bookingDurationHours))
        let voucherRow = makeSummaryRow(title: text(.discount), value: selectedDiscountAmount > 0 ? "-\(currencyText(selectedDiscountAmount))" : zeroCurrencyText, highlight: true)
        let totalRow = makeSummaryRow(title: text(.total), value: currencyText(totalAmount), titleFont: .boldSystemFont(ofSize: 16), valueFont: .boldSystemFont(ofSize: 22), highlight: true)

        totalAmountLabel.font = .boldSystemFont(ofSize: 22)

        card.addArrangedSubview(title)
        card.addArrangedSubview(priceRow)
        card.addArrangedSubview(voucherRow)
        card.addArrangedSubview(makeDivider())
        card.addArrangedSubview(totalRow)
        return card
    }

    private func makeSectionContainer(title: String, trailingView: UIView? = nil) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.text = title

        let header = UIStackView(arrangedSubviews: [titleLabel])
        header.axis = .horizontal
        header.distribution = .equalSpacing
        if let trailingView {
            header.addArrangedSubview(trailingView)
        }

        stack.addArrangedSubview(header)
        return stack
    }

    private func makeHorizontalButtonStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }

    private func makeSelectableButton(title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        button.configuration = configuration
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.backgroundColor = .white
        button.setTitleColor(.label, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    private func makeCourtButtonConfiguration(title: String, subtitle: String, selected: Bool) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        var attributedTitle = AttributedString(title)
        attributedTitle.font = .boldSystemFont(ofSize: 16)
        configuration.attributedTitle = attributedTitle

        var attributedSubtitle = AttributedString(subtitle)
        attributedSubtitle.font = .systemFont(ofSize: 14)
        configuration.attributedSubtitle = attributedSubtitle
        configuration.titleAlignment = .leading
        configuration.image = UIImage(systemName: selected ? "checkmark.circle.fill" : "circle")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.baseForegroundColor = selected ? .systemMint : .label
        configuration.background.backgroundColor = selected ? UIColor.systemMint.withAlphaComponent(0.08) : .white
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return configuration
    }

    private func makeSummaryRow(title: String, value: String, titleFont: UIFont = .systemFont(ofSize: 14), valueFont: UIFont = .systemFont(ofSize: 14, weight: .semibold), highlight: Bool = false) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = titleFont
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.font = valueFont
        valueLabel.textColor = highlight ? .systemMint : .label
        valueLabel.text = value

        if title.hasPrefix("Giá sân") {
            priceAmountLabel.font = valueFont
            priceAmountLabel.textColor = .label
            priceAmountLabel.text = value
            return makeRow(left: titleLabel, right: priceAmountLabel)
        }

        if title == text(.discount) {
            voucherAmountLabel.font = valueFont
            voucherAmountLabel.textColor = .systemMint
            voucherAmountLabel.text = value
            return makeRow(left: titleLabel, right: voucherAmountLabel)
        }

        if title == text(.total) {
            totalAmountLabel.text = value
            return makeRow(left: titleLabel, right: totalAmountLabel)
        }

        return makeRow(left: titleLabel, right: valueLabel)
    }

    private func makeRow(left: UIView, right: UIView) -> UIView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.distribution = .equalSpacing
        return row
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .systemGray5
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    private func makePrimaryButtonConfiguration(title: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = .systemMint
        configuration.baseForegroundColor = .label
        return configuration
    }

    private func makeSecondaryButtonConfiguration(title: String) -> UIButton.Configuration {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .large
        configuration.baseBackgroundColor = UIColor(red: 0.06, green: 0.14, blue: 0.10, alpha: 1)
        configuration.baseForegroundColor = .white
        return configuration
    }

    private var selectedCourtPrice: Double {
        guard courts.indices.contains(selectedCourtIndex) else { return 0 }
        return courts[selectedCourtIndex].pricePerHour
    }

    private var summaryPriceTitle: String {
        let durationText = bookingDurationHours == floor(bookingDurationHours)
            ? "\(Int(bookingDurationHours)) \(text(bookingDurationHours == 1 ? .hourSingular : .hourPlural))"
            : String(format: currentLanguage == .english ? "%.1f hours" : "%.1f giờ", bookingDurationHours)
        return "\(text(.courtPrice)) (\(durationText))"
    }

    private var bookingDurationHours: Double {
        resolvedEndTime.timeIntervalSince(resolvedStartTime) / 3600
    }

    private var totalAmount: Double {
        max((selectedCourtPrice * bookingDurationHours) - selectedDiscountAmount, 0)
    }

    private var selectedDiscountAmount: Double {
        appliedDiscountAmount
    }

    private var resolvedBookingDate: Date {
        availableDates[selectedDateIndex]
    }

    private var resolvedStartTime: Date {
        let selectedTime = availableTimes[selectedTimeIndex]
        let components = selectedTime.split(separator: ":")
        let hour = Int(components.first ?? "18") ?? 18
        let minute = Int(components.last ?? "00") ?? 0
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: resolvedBookingDate) ?? resolvedBookingDate
    }

    private var resolvedEndTime: Date {
        calendar.date(byAdding: .minute, value: 90, to: resolvedStartTime) ?? resolvedStartTime
    }

    private func updateDateSelectionUI() {
        selectedDateLabel.text = longDateTitle(for: resolvedBookingDate)
        for (index, button) in dateButtons.enumerated() {
            let isSelected = index == selectedDateIndex
            button.backgroundColor = isSelected ? .systemMint : .white
            button.layer.borderColor = (isSelected ? UIColor.systemMint : UIColor.systemGray5).cgColor
            button.setTitleColor(isSelected ? .label : .label, for: .normal)
        }
        ensureSelectedTimeIsValid()
        updateTimeSelectionUI()
        updateSummary()
    }

    private func updateTimeSelectionUI() {
        for (index, button) in timeButtons.enumerated() {
            let isSelected = index == selectedTimeIndex
            let isEnabled = isTimeSelectable(at: index)
            button.isEnabled = isEnabled
            button.alpha = isEnabled ? 1 : 0.4
            button.backgroundColor = isSelected && isEnabled ? .systemMint : .white
            button.layer.borderColor = (isSelected && isEnabled ? UIColor.systemMint : UIColor.systemGray5).cgColor
        }
        updateSummary()
    }

    private func updateCourtSelectionUI() {
        for (index, button) in courtButtons.enumerated() {
            button.configuration = makeCourtButtonConfiguration(
                title: courts[index].name,
                subtitle: "\(courts[index].priceText)/\(text(.hourSingular))",
                selected: index == selectedCourtIndex
            )
        }
        updateSummary()
    }

    private func updateSummary() {
        priceAmountLabel.text = currencyText(selectedCourtPrice * bookingDurationHours)
        voucherAmountLabel.text = selectedDiscountAmount > 0 ? "-\(currencyText(selectedDiscountAmount))" : zeroCurrencyText
        totalAmountLabel.text = currencyText(totalAmount)
        let durationText = bookingDurationHours == floor(bookingDurationHours)
            ? "\(Int(bookingDurationHours)) \(text(bookingDurationHours == 1 ? .hourSingular : .hourPlural))"
            : String(format: currentLanguage == .english ? "%.1f hours" : "%.1f giờ", bookingDurationHours)
        confirmButton.configuration?.subtitle = "\(shortDateTitle(for: resolvedBookingDate)) • \(apiTimeText(from: resolvedStartTime))-\(apiTimeText(from: resolvedEndTime)) • \(durationText)"
    }

    private func currencyText(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: currencyLocaleIdentifier)
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? zeroCurrencyText
    }

    @objc private func backTapped() {
        handleBackNavigation()
    }

    @objc private func applyVoucherTapped() {
        let voucher = voucherTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
        guard voucher.isEmpty == false else {
            appliedVoucherCode = nil
            appliedDiscountAmount = 0
            isVoucherApplied = false
            showAlert(title: text(.missingCode), message: text(.enterVoucherCodeMessage))
            return
        }

        Task { [weak self] in
            guard let self else { return }

            do {
                let preview = try await vouchersService.previewVoucherApplication(
                    code: voucher,
                    bookingAmount: selectedCourtPrice * bookingDurationHours,
                    courtType: selectedCourtType
                )

                await MainActor.run {
                    self.appliedVoucherCode = preview.code
                    self.appliedDiscountAmount = preview.discountAmount
                    self.isVoucherApplied = preview.applied && preview.discountAmount > 0
                    let message = preview.message ?? self.localized("Đã áp dụng mã giảm giá \(preview.code).", "Voucher \(preview.code) has been applied.")
                    self.showAlert(title: self.text(.success), message: message)
                }
            } catch {
                await MainActor.run {
                    self.appliedVoucherCode = nil
                    self.appliedDiscountAmount = 0
                    self.isVoucherApplied = false
                    self.showAlert(title: self.text(.invalid), message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func confirmBookingTapped() {
        guard validateBookingSelection() else { return }

        confirmButton.isEnabled = false
        confirmButton.configuration?.showsActivityIndicator = true

        Task { [weak self] in
            guard let self else { return }

            do {
                let persistedUser = BackendAuthService.shared.restorePersistedUser()
                guard let userId = persistedUser?.id, !userId.isEmpty else {
                    throw BackendBookingsError.missingUserSession
                }

                let bookingCode = "BK-\(Int(Date().timeIntervalSince1970))"
                let payload = BackendBookingPayload(
                    id: UUID().uuidString,
                    userId: userId,
                    courtId: selectedCourtID,
                    bookingCode: bookingCode,
                    bookingDate: apiDateText(from: resolvedBookingDate),
                    startTime: apiTimeText(from: resolvedStartTime),
                    endTime: apiTimeText(from: resolvedEndTime),
                    durationHours: bookingDurationHours,
                    pricePerHour: selectedCourtPrice,
                    totalAmount: totalAmount,
                    bookingStatus: "Pending",
                    paymentStatus: "Pending",
                    createdBy: persistedUser?.email ?? "user"
                )

                let booking = try await bookingsService.createBooking(payload)

                await MainActor.run {
                    self.systemLogStore.append(
                        title: self.text(.createBookingLogTitle),
                        message: "Khách đã tạo booking \(booking.bookingCode) cho sân \(booking.courtName) lúc \(booking.startTime)-\(booking.endTime).",
                        source: "booking"
                    )
                    self.confirmButton.isEnabled = true
                    self.confirmButton.configuration?.showsActivityIndicator = false

                    guard let paymentViewController = PaymentMethodViewController.instantiate(amount: self.totalAmount, bookingId: booking.id) else {
                        self.showAlert(title: self.text(.error), message: self.text(.unableToOpenPaymentScreen))
                        return
                    }

                    if let navigationController = self.navigationController {
                        navigationController.pushViewController(paymentViewController, animated: true)
                    } else {
                        let navigationController = UINavigationController(rootViewController: paymentViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        self.present(navigationController, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    self.confirmButton.isEnabled = true
                    self.confirmButton.configuration?.showsActivityIndicator = false
                    self.showAlert(title: self.text(.unableToCreateBooking), message: error.localizedDescription)
                }
            }
        }
    }

    private func apiDateText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func apiTimeText(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func makeAvailableDates() -> [Date] {
        let startOfToday = calendar.startOfDay(for: Date())
        return (0..<5).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfToday) }
    }

    private func shortDateTitle(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return text(.today)
        }

        if calendar.isDateInTomorrow(date) {
            return text(.tomorrow)
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: dateLocaleIdentifier)
        formatter.dateFormat = currentLanguage == .english ? "E, dd/MM" : "EEE dd/MM"
        return formatter.string(from: date).capitalized
    }

    private func longDateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: dateLocaleIdentifier)
        formatter.dateFormat = currentLanguage == .english ? "EEEE, MM/dd/yyyy" : "EEEE, dd/MM/yyyy"
        return formatter.string(from: date).capitalized
    }

    private func bookingDateForTime(at index: Int) -> Date {
        let selectedTime = availableTimes[index]
        let components = selectedTime.split(separator: ":")
        let hour = Int(components.first ?? "18") ?? 18
        let minute = Int(components.last ?? "00") ?? 0
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: resolvedBookingDate) ?? resolvedBookingDate
    }

    private func isTimeSelectable(at index: Int) -> Bool {
        bookingDateForTime(at: index) >= Date()
    }

    private func ensureSelectedTimeIsValid() {
        guard isTimeSelectable(at: selectedTimeIndex) == false else { return }
        if let firstValidIndex = availableTimes.indices.first(where: { isTimeSelectable(at: $0) }) {
            selectedTimeIndex = firstValidIndex
        }
    }

    private func validateBookingSelection() -> Bool {
        if courts.isEmpty {
            showAlert(title: text(.noCourtsAvailable), message: text(.unableToLoadCourtsFromBackend))
            return false
        }

        if resolvedBookingDate < calendar.startOfDay(for: Date()) {
            showAlert(title: text(.invalidDate), message: text(.invalidDateMessage))
            return false
        }

        if isTimeSelectable(at: selectedTimeIndex) == false {
            showAlert(title: text(.invalidTime), message: text(.invalidTimeMessage))
            return false
        }

        if resolvedEndTime <= resolvedStartTime {
            showAlert(title: text(.invalidTimeRange), message: text(.invalidTimeRangeMessage))
            return false
        }

        return true
    }

    private var selectedCourtID: String {
        guard courts.indices.contains(selectedCourtIndex) else { return "" }
        return courts[selectedCourtIndex].id
    }

    private var selectedCourtType: String? {
        guard courts.indices.contains(selectedCourtIndex) else { return nil }
        return courts[selectedCourtIndex].type
    }

    private func loadCourts() {
        Task { [weak self] in
            guard let self else { return }

            do {
                let fetchedCourts = try await courtsService.fetchCourtOptions()
                await MainActor.run {
                    self.courts = fetchedCourts.filter { $0.status.caseInsensitiveCompare("Active") == .orderedSame || $0.status.caseInsensitiveCompare("Available") == .orderedSame }
                    if self.courts.isEmpty {
                        self.courts = fetchedCourts
                    }
                    self.applyPreselectedCourtIfNeeded()
                    self.selectedCourtIndex = min(self.selectedCourtIndex, max(self.courts.count - 1, 0))
                    self.renderCourtOptions()
                    self.updateSummary()
                }
            } catch {
                await MainActor.run {
                    self.courts = []
                    self.renderCourtOptions(message: self.text(.unableToLoadCourtsFromBackend))
                }
            }
        }
    }

    private func renderCourtOptions(message: String? = nil) {
        courtSectionStack.arrangedSubviews.forEach { view in
            courtSectionStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        guard courts.isEmpty == false else {
            let stateLabel = UILabel()
            stateLabel.font = .systemFont(ofSize: 14)
            stateLabel.textColor = .secondaryLabel
            stateLabel.numberOfLines = 0
            stateLabel.text = message ?? text(.loadingCourts)
            courtSectionStack.addArrangedSubview(stateLabel)
            confirmButton.isEnabled = false
            return
        }

        confirmButton.isEnabled = true
        courtButtons = courts.enumerated().map { index, court in
            let button = UIButton(type: .system)
            button.configuration = makeCourtButtonConfiguration(
                title: court.name,
                subtitle: court.priceText,
                selected: index == selectedCourtIndex
            )
            button.addAction(UIAction { [weak self] _ in
                self?.selectedCourtIndex = index
            }, for: .touchUpInside)
            courtSectionStack.addArrangedSubview(button)
            return button
        }
    }

    private func applyPreselectedCourtIfNeeded() {
        if let preselectedCourtID,
           let index = courts.firstIndex(where: { $0.id.caseInsensitiveCompare(preselectedCourtID) == .orderedSame }) {
            selectedCourtIndex = index
            return
        }

        if let preselectedCourtName,
           let index = courts.firstIndex(where: { $0.name.caseInsensitiveCompare(preselectedCourtName) == .orderedSame }) {
            selectedCourtIndex = index
        }
    }

    private var zeroCurrencyText: String {
        currentLanguage == .english ? "$0" : "0 đ"
    }

    private var currencyLocaleIdentifier: String {
        currentLanguage == .english ? "en_US" : "vi_VN"
    }

    private var dateLocaleIdentifier: String {
        currentLanguage == .english ? "en_US" : "vi_VN"
    }

    private func localized(_ vietnamese: String, _ english: String) -> String {
        AppLocalization.localized(vi: vietnamese, en: english)
    }

    private func text(_ key: AppLocalizedKey) -> String {
        AppLocalization.text(key)
    }
}

import UIKit

final class RevenueReportViewController: StoryboardScreenViewController {
    @IBOutlet private weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var revenueValueLabel: UILabel!
    @IBOutlet private weak var revenueTrendLabel: UILabel!
    @IBOutlet private weak var revenueTrendImageView: UIImageView!
    @IBOutlet private weak var secondaryMetricTitleLabel: UILabel!
    @IBOutlet private weak var secondaryMetricValueLabel: UILabel!
    @IBOutlet private weak var secondaryMetricTrendLabel: UILabel!
    @IBOutlet private weak var secondaryMetricTrendImageView: UIImageView!
    @IBOutlet private weak var chartTitleLabel: UILabel!
    @IBOutlet private weak var chartSubtitleLabel: UILabel!
    @IBOutlet private weak var legendPrimaryLabel: UILabel!
    @IBOutlet private weak var legendSecondaryLabel: UILabel!
    @IBOutlet private weak var chartBackgroundView: UIView!
    @IBOutlet private weak var chartDaysStackView: UIStackView!
    @IBOutlet private weak var dayFilterButton: UIButton!
    @IBOutlet private weak var weekFilterButton: UIButton!
    @IBOutlet private weak var monthFilterButton: UIButton!
    @IBOutlet private weak var yearFilterButton: UIButton!

    private let adminService = BackendAdminService.shared
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private var overview: BackendAdminOverview?
    private var courts: [BackendAdminCourt] = []
    private var bookings: [BackendBookingRecord] = []
    private var payments: [BackendAdminPayment] = []
    private var selectedPeriod: RevenuePeriod = .day

    override var screenTitleText: String {
        "Báo cáo doanh thu"
    }

    override var screenSubtitleText: String {
        "Màn hình tổng hợp doanh thu, tỷ lệ thanh toán và xu hướng booking từ backend admin."
    }

    override var screenHighlights: [String] {
        guard let overview else {
            return [
                "Đang đồng bộ doanh thu từ backend",
                "Tổng hợp booking, payment và số sân",
                "Có lọc theo ngày, tuần, tháng, năm"
            ]
        }

        return [
            "Tổng doanh thu backend: \(currencyText(overview.totalRevenue))",
            "Tổng booking: \(overview.totalBookings) • Thanh toán: \(overview.totalPayments)",
            "Số sân đang quản lý: \(overview.totalCourts)"
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureStaticUI()
        renderLoadingState()
        loadReport()
    }

    private func configureStaticUI() {
        contentHeightConstraint.constant = 600
        [dayFilterButton, weekFilterButton, monthFilterButton, yearFilterButton].forEach {
            $0?.layer.cornerRadius = 8
            $0?.clipsToBounds = true
        }
        chartBackgroundView.clipsToBounds = true
        updateFilterStyles()
        legendPrimaryLabel.text = "Doanh thu"
        legendSecondaryLabel.text = "Giao dịch"
    }

    private func loadReport() {
        Task { [weak self] in
            guard let self else { return }

            do {
                async let overviewTask = adminService.fetchOverview()
                async let courtsTask = adminService.fetchCourts()
                async let bookingsTask = adminService.fetchBookings()
                async let paymentsTask = adminService.fetchPayments()

                let (overview, courts, bookings, payments) = try await (
                    overviewTask,
                    courtsTask,
                    bookingsTask,
                    paymentsTask
                )

                await MainActor.run {
                    self.overview = overview
                    self.courts = courts
                    self.bookings = bookings
                    self.payments = payments
                    self.renderReport()
                }
            } catch {
                await MainActor.run {
                    self.renderErrorState(error.localizedDescription)
                }
            }
        }
    }

    private func renderLoadingState() {
        revenueValueLabel.text = "..."
        revenueTrendLabel.text = "Đang tải"
        secondaryMetricTitleLabel.text = "Tỷ lệ thanh toán"
        secondaryMetricValueLabel.text = "--"
        secondaryMetricTrendLabel.text = "Đang tải dữ liệu"
        chartTitleLabel.text = "Xu hướng doanh thu"
        chartSubtitleLabel.text = "Đang đồng bộ booking và payment từ backend."
        renderChart(points: Array(repeating: .init(label: "--", revenue: 0, count: 0), count: 7))
    }

    private func renderErrorState(_ message: String) {
        revenueValueLabel.text = "--"
        revenueTrendLabel.text = "Không tải được"
        secondaryMetricTitleLabel.text = "Tỷ lệ thanh toán"
        secondaryMetricValueLabel.text = "--"
        secondaryMetricTrendLabel.text = message
        chartTitleLabel.text = "Xu hướng doanh thu"
        chartSubtitleLabel.text = "Kiểm tra API admin để tải dữ liệu báo cáo."
        renderChart(points: Array(repeating: .init(label: "--", revenue: 0, count: 0), count: 7))
    }

    private func renderReport() {
        let currentRange = dateInterval(for: selectedPeriod, referenceDate: Date())
        let previousRange = previousInterval(for: currentRange, period: selectedPeriod)

        let currentBookings = bookings.filter { booking in
            guard let bookingDate = parsedBookingDate(from: booking.bookingDate) else { return false }
            return currentRange.contains(bookingDate)
        }
        let previousBookings = bookings.filter { booking in
            guard let bookingDate = parsedBookingDate(from: booking.bookingDate) else { return false }
            return previousRange.contains(bookingDate)
        }

        let currentPaidBookings = currentBookings.filter(isPaidBooking(_:))
        let previousPaidBookings = previousBookings.filter(isPaidBooking(_:))

        let currentRevenue = currentPaidBookings.reduce(0) { $0 + $1.totalAmount }
        let previousRevenue = previousPaidBookings.reduce(0) { $0 + $1.totalAmount }

        let currentPaymentRate = currentBookings.isEmpty ? 0 : Double(currentPaidBookings.count) / Double(currentBookings.count)
        let previousPaymentRate = previousBookings.isEmpty ? 0 : Double(previousPaidBookings.count) / Double(previousBookings.count)

        revenueValueLabel.text = currencyText(currentRevenue)
        applyTrend(
            currentValue: currentRevenue,
            previousValue: previousRevenue,
            label: revenueTrendLabel,
            imageView: revenueTrendImageView,
            suffix: nil
        )

        secondaryMetricTitleLabel.text = "Tỷ lệ thanh toán"
        secondaryMetricValueLabel.text = percentageText(currentPaymentRate)
        applyTrend(
            currentValue: currentPaymentRate,
            previousValue: previousPaymentRate,
            label: secondaryMetricTrendLabel,
            imageView: secondaryMetricTrendImageView,
            suffix: " so với kỳ trước"
        )

        chartTitleLabel.text = "Xu hướng doanh thu"
        chartSubtitleLabel.text = summaryText(
            currentBookings: currentBookings,
            currentPaidBookings: currentPaidBookings,
            currentRange: currentRange
        )

        let chartPoints = chartPoints(for: selectedPeriod, range: currentRange, bookings: currentBookings)
        renderChart(points: chartPoints)
    }

    private func applyTrend(
        currentValue: Double,
        previousValue: Double,
        label: UILabel,
        imageView: UIImageView,
        suffix: String?
    ) {
        let delta = currentValue - previousValue
        let comparisonText: String
        if previousValue == 0 {
            comparisonText = currentValue == 0 ? "Không đổi" : "Tăng mới"
        } else {
            let percent = (delta / previousValue) * 100
            let prefix = percent >= 0 ? "+" : ""
            comparisonText = "\(prefix)\(String(format: "%.1f", percent))%\((suffix ?? ""))"
        }

        label.text = comparisonText
        if delta > 0 {
            label.textColor = UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 1)
            imageView.image = UIImage(systemName: "arrow.up.right")
            imageView.tintColor = UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 1)
        } else if delta < 0 {
            label.textColor = .systemRed
            imageView.image = UIImage(systemName: "arrow.down.right")
            imageView.tintColor = .systemRed
        } else {
            label.textColor = .secondaryLabel
            imageView.image = UIImage(systemName: "arrow.right")
            imageView.tintColor = .secondaryLabel
        }
    }

    private func summaryText(
        currentBookings: [BackendBookingRecord],
        currentPaidBookings: [BackendBookingRecord],
        currentRange: DateInterval
    ) -> String {
        let distinctCourts = Set(currentBookings.map(\.courtId)).count
        let occupancy = courts.isEmpty ? 0 : Double(distinctCourts) / Double(courts.count)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "dd/MM"

        return "\(formatter.string(from: currentRange.start)) - \(formatter.string(from: currentRange.end.addingTimeInterval(-1))) • \(currentPaidBookings.count) giao dịch • Phủ sân \(percentageText(occupancy))"
    }

    private func renderChart(points: [RevenueChartPoint]) {
        chartDaysStackView.arrangedSubviews.enumerated().forEach { index, view in
            guard let label = view as? UILabel, points.indices.contains(index) else { return }
            label.text = points[index].label
        }

        chartBackgroundView.subviews
            .filter { $0.tag == 777 }
            .forEach { $0.removeFromSuperview() }

        let stackView = UIStackView()
        stackView.tag = 777
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        stackView.distribution = .fillEqually
        stackView.spacing = 10

        let maxRevenue = max(points.map(\.revenue).max() ?? 0, 1)
        let maxCount = max(points.map(\.count).max() ?? 0, 1)

        for point in points {
            stackView.addArrangedSubview(makeChartColumn(point: point, maxRevenue: maxRevenue, maxCount: maxCount))
        }

        chartBackgroundView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: chartBackgroundView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: chartBackgroundView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: chartBackgroundView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: chartBackgroundView.bottomAnchor, constant: -12)
        ])
    }

    private func makeChartColumn(point: RevenueChartPoint, maxRevenue: Double, maxCount: Int) -> UIView {
        let container = UIView()

        let revenueBar = UIView()
        revenueBar.translatesAutoresizingMaskIntoConstraints = false
        revenueBar.backgroundColor = UIColor(red: 0.0, green: 0.9019, blue: 0.4666, alpha: 1)
        revenueBar.layer.cornerRadius = 4

        let countBar = UIView()
        countBar.translatesAutoresizingMaskIntoConstraints = false
        countBar.backgroundColor = UIColor.systemGray3
        countBar.layer.cornerRadius = 4

        container.addSubview(revenueBar)
        container.addSubview(countBar)

        let revenueHeight = max(8, CGFloat(point.revenue / maxRevenue) * 96)
        let countHeight = max(8, CGFloat(Double(point.count) / Double(maxCount)) * 96)

        NSLayoutConstraint.activate([
            revenueBar.widthAnchor.constraint(equalToConstant: 10),
            revenueBar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            revenueBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            revenueBar.heightAnchor.constraint(equalToConstant: revenueHeight),

            countBar.widthAnchor.constraint(equalToConstant: 10),
            countBar.leadingAnchor.constraint(equalTo: revenueBar.trailingAnchor, constant: 4),
            countBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            countBar.heightAnchor.constraint(equalToConstant: countHeight),
            countBar.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6)
        ])

        return container
    }

    private func chartPoints(
        for period: RevenuePeriod,
        range: DateInterval,
        bookings: [BackendBookingRecord]
    ) -> [RevenueChartPoint] {
        switch period {
        case .day:
            let labels = ["06h", "08h", "10h", "12h", "14h", "16h", "18h"]
            return labels.enumerated().map { index, label in
                let lowerHour = 6 + (index * 2)
                let upperHour = lowerHour + 2
                let matching = bookings.filter { booking in
                    guard let date = parsedBookingDate(from: booking.bookingDate),
                          Calendar.current.isDate(date, inSameDayAs: range.start),
                          let hour = parsedHour(from: booking.startTime) else { return false }
                    return hour >= lowerHour && hour < upperHour
                }
                return RevenueChartPoint(label: label, revenue: matching.filter(isPaidBooking(_:)).reduce(0) { $0 + $1.totalAmount }, count: matching.count)
            }
        case .week:
            let calendar = Calendar(identifier: .gregorian)
            return (0..<7).map { offset in
                let day = calendar.date(byAdding: .day, value: offset, to: range.start) ?? range.start
                let matching = bookings.filter {
                    guard let date = parsedBookingDate(from: $0.bookingDate) else { return false }
                    return calendar.isDate(date, inSameDayAs: day)
                }
                let label = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"][offset]
                return RevenueChartPoint(label: label, revenue: matching.filter(isPaidBooking(_:)).reduce(0) { $0 + $1.totalAmount }, count: matching.count)
            }
        case .month:
            let labels = ["01", "05", "10", "15", "20", "25", "30"]
            let boundaries = [1, 5, 10, 15, 20, 25, 30, 32]
            return (0..<7).map { index in
                let lowerDay = boundaries[index]
                let upperDay = boundaries[index + 1]
                let matching = bookings.filter {
                    guard let date = parsedBookingDate(from: $0.bookingDate) else { return false }
                    let day = Calendar.current.component(.day, from: date)
                    return day >= lowerDay && day < upperDay
                }
                return RevenueChartPoint(label: labels[index], revenue: matching.filter(isPaidBooking(_:)).reduce(0) { $0 + $1.totalAmount }, count: matching.count)
            }
        case .year:
            let labels = ["T1", "T3", "T5", "T7", "T9", "T11", "T12"]
            let months = [1, 3, 5, 7, 9, 11, 12]
            return months.enumerated().map { index, month in
                let matching = bookings.filter {
                    guard let date = parsedBookingDate(from: $0.bookingDate) else { return false }
                    return Calendar.current.component(.month, from: date) == month
                }
                return RevenueChartPoint(label: labels[index], revenue: matching.filter(isPaidBooking(_:)).reduce(0) { $0 + $1.totalAmount }, count: matching.count)
            }
        }
    }

    private func isPaidBooking(_ booking: BackendBookingRecord) -> Bool {
        let paymentStatus = booking.paymentStatus.lowercased()
        let bookingStatus = booking.bookingStatus.lowercased()
        return paymentStatus == "paid" || bookingStatus == "fully paid" || bookingStatus == "confirmed" || bookingStatus == "active" || bookingStatus == "checked_in"
    }

    private func parsedBookingDate(from raw: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.calendar = Calendar(identifier: .gregorian)

        for format in ["yyyy-MM-dd", "dd/MM/yyyy", "d/M/yyyy"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                return date
            }
        }

        return nil
    }

    private func parsedHour(from raw: String) -> Int? {
        Int(raw.split(separator: ":").first ?? "")
    }

    private func dateInterval(for period: RevenuePeriod, referenceDate: Date) -> DateInterval {
        let calendar = Calendar(identifier: .gregorian)
        switch period {
        case .day:
            let start = calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .month:
            let start = calendar.dateInterval(of: .month, for: referenceDate)?.start ?? calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? referenceDate
            return DateInterval(start: start, end: end)
        case .year:
            let start = calendar.dateInterval(of: .year, for: referenceDate)?.start ?? calendar.startOfDay(for: referenceDate)
            let end = calendar.date(byAdding: .year, value: 1, to: start) ?? referenceDate
            return DateInterval(start: start, end: end)
        }
    }

    private func previousInterval(for interval: DateInterval, period: RevenuePeriod) -> DateInterval {
        let calendar = Calendar(identifier: .gregorian)
        switch period {
        case .day:
            let start = calendar.date(byAdding: .day, value: -1, to: interval.start) ?? interval.start
            return DateInterval(start: start, end: interval.start)
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: interval.start) ?? interval.start
            return DateInterval(start: start, end: interval.start)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: interval.start) ?? interval.start
            return DateInterval(start: start, end: interval.start)
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: interval.start) ?? interval.start
            return DateInterval(start: start, end: interval.start)
        }
    }

    private func currencyText(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "0 đ"
    }

    private func percentageText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func updateFilterStyles() {
        let mapping: [(UIButton?, RevenuePeriod)] = [
            (dayFilterButton, .day),
            (weekFilterButton, .week),
            (monthFilterButton, .month),
            (yearFilterButton, .year)
        ]

        mapping.forEach { button, period in
            let isSelected = selectedPeriod == period
            button?.backgroundColor = isSelected ? .white : .clear
            button?.setTitleColor(isSelected ? .label : .secondaryLabel, for: .normal)
        }
    }

    @IBAction private func backTapped(_ sender: UIButton) {
        handleBackNavigation()
    }

    @IBAction private func refreshTapped(_ sender: UIButton) {
        loadReport()
    }

    @IBAction private func dayFilterTapped(_ sender: UIButton) {
        selectedPeriod = .day
        updateFilterStyles()
        renderReport()
    }

    @IBAction private func weekFilterTapped(_ sender: UIButton) {
        selectedPeriod = .week
        updateFilterStyles()
        renderReport()
    }

    @IBAction private func monthFilterTapped(_ sender: UIButton) {
        selectedPeriod = .month
        updateFilterStyles()
        renderReport()
    }

    @IBAction private func yearFilterTapped(_ sender: UIButton) {
        selectedPeriod = .year
        updateFilterStyles()
        renderReport()
    }
}

private extension RevenueReportViewController {
    enum RevenuePeriod {
        case day
        case week
        case month
        case year
    }

    struct RevenueChartPoint {
        let label: String
        let revenue: Double
        let count: Int
    }
}

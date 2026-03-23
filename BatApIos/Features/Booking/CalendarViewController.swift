import UIKit

final class CalendarViewController: UIViewController {

    @IBOutlet private weak var calendarCollectionView: UICollectionView!

    private let calendar = Calendar.current
    private var selectedDate = Date()
    private var visibleDates: [Date] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        reloadDates()
    }

    private func configureCollectionView() {
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
    }

    private func reloadDates() {
        visibleDates = (-3...10).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: selectedDate)
        }
        calendarCollectionView.reloadData()
    }

    @IBAction private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleDates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDayCell.reuseIdentifier,
            for: indexPath
        ) as? CalendarDayCell else {
            return UICollectionViewCell()
        }

        cell.configure(
            with: visibleDates[indexPath.item],
            calendar: calendar,
            isSelected: calendar.isDate(visibleDates[indexPath.item], inSameDayAs: selectedDate)
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDate = visibleDates[indexPath.item]
        collectionView.reloadData()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: 92)
    }
}

private final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell"

    private let dayLabel = UILabel()
    private let weekdayLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor

        dayLabel.font = .boldSystemFont(ofSize: 22)
        dayLabel.textAlignment = .center

        weekdayLabel.font = .systemFont(ofSize: 13, weight: .medium)
        weekdayLabel.textAlignment = .center
        weekdayLabel.textColor = .secondaryLabel

        let stackView = UIStackView(arrangedSubviews: [dayLabel, weekdayLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with date: Date, calendar: Calendar, isSelected: Bool) {
        dayLabel.text = String(calendar.component(.day, from: date))

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE"
        weekdayLabel.text = formatter.string(from: date).capitalized

        if isSelected {
            contentView.backgroundColor = UIColor.systemMint.withAlphaComponent(0.16)
            contentView.layer.borderColor = UIColor.systemMint.cgColor
            dayLabel.textColor = .label
        } else {
            contentView.backgroundColor = .systemBackground
            contentView.layer.borderColor = UIColor.systemGray5.cgColor
            dayLabel.textColor = .label
        }
    }
}

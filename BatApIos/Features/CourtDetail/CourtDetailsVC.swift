
import UIKit
import MapKit

// MARK: - Data Model
struct CourtModel {
    var name: String
    var pricePerHour: String
    var address: String
    var rating: String
    var description: String
    var imageName: String?
    var latitude: Double
    var longitude: Double
}

class CourtDetailsVC: UIViewController {

    // MARK: - Data
    var court: CourtModel = CourtModel(
        name: "Sân Cầu Lông CodeForApp",
        pricePerHour: "150.000đ / Giờ",
        address: "📍  Sư Vạn Hạnh, Quận 10, TP.HCM",
        rating: "⭐  4.8  (120 đánh giá)",
        description: "Sân thảm chất lượng cao, ánh sáng đạt chuẩn thi đấu quốc tế. Khu vực bãi đỗ xe rộng rãi cho xe máy và ô tô. Có căng-tin nước và khu vực chờ máy lạnh. Cho thuê vợt và bóng theo giờ.",
        imageName: nil,
        latitude: 10.7769,
        longitude: 106.6953
    )

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let courtImageView = UIImageView()
    private let courtNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let addressLabel = UILabel()
    private let ratingLabel = UILabel()
    private let descLabel = UILabel()
    private let amenitiesStack = UIStackView()
    private let mapView = MKMapView()
    
    private let backButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    private let bookButton = UIButton(type: .system)

    private let themeGreen = UIColor(red: 0.0, green: 0.82, blue: 0.38, alpha: 1.0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        setupMap()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 1. Setup ScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // 2. Setup Subviews
        [courtImageView, courtNameLabel, priceLabel, ratingLabel, addressLabel, amenitiesStack, descLabel, mapView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [backButton, favoriteButton, bookButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 3. Configure Appearance
        courtImageView.contentMode = .scaleAspectFill
        courtImageView.clipsToBounds = true
        courtImageView.backgroundColor = .systemGray6
        
        courtNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        courtNameLabel.numberOfLines = 2
        
        priceLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        priceLabel.textColor = themeGreen
        
        ratingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0
        
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        
        amenitiesStack.axis = .horizontal
        amenitiesStack.spacing = 12
        amenitiesStack.distribution = .fillEqually
        
        mapView.layer.cornerRadius = 16
        mapView.clipsToBounds = true
        
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.backgroundColor = .white
        backButton.layer.cornerRadius = 20
        backButton.tintColor = .black
        
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.backgroundColor = .white
        favoriteButton.layer.cornerRadius = 20
        favoriteButton.tintColor = .black
        
        bookButton.setTitle("Đặt sân ngay", for: .normal)
        bookButton.backgroundColor = themeGreen
        bookButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        bookButton.setTitleColor(.white, for: .normal)
        bookButton.layer.cornerRadius = 14
        
        // 4. Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bookButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            courtImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            courtImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            courtImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            courtImageView.heightAnchor.constraint(equalToConstant: 280),
            
            courtNameLabel.topAnchor.constraint(equalTo: courtImageView.bottomAnchor, constant: 20),
            courtNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            courtNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: courtNameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            ratingLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            addressLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            amenitiesStack.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 20),
            amenitiesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            amenitiesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            amenitiesStack.heightAnchor.constraint(equalToConstant: 60),
            
            descLabel.topAnchor.constraint(equalTo: amenitiesStack.bottomAnchor, constant: 20),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            mapView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mapView.heightAnchor.constraint(equalToConstant: 180),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),
            
            bookButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bookButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        // 5. Add Amenities
        let items = [("car.fill", "Bãi xe"), ("wifi", "Wi-Fi"), ("cup.and.saucer.fill", "Căng-tin"), ("shower.fill", "Phòng tắm")]
        for (icon, title) in items {
            amenitiesStack.addArrangedSubview(makeAmenityChip(icon: icon, title: title))
        }
    }

    private func makeAmenityChip(icon: String, title: String) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        v.layer.cornerRadius = 12
        let img = UIImageView(image: UIImage(systemName: icon))
        img.contentMode = .scaleAspectFit
        let lbl = UILabel()
        lbl.text = title
        lbl.font = .systemFont(ofSize: 10, weight: .medium)
        lbl.textAlignment = .center
        v.addSubview(img)
        v.addSubview(lbl)
        img.translatesAutoresizingMaskIntoConstraints = false
        lbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
            img.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            img.widthAnchor.constraint(equalToConstant: 20),
            img.heightAnchor.constraint(equalToConstant: 20),
            lbl.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 4),
            lbl.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 2),
            lbl.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -2)
        ])
        return v
    }

    private func populateData() {
        courtNameLabel.text = court.name
        priceLabel.text = court.pricePerHour
        addressLabel.text = court.address
        ratingLabel.text = court.rating
        descLabel.text = court.description
    }

    private func setupMap() {
        let coord = CLLocationCoordinate2D(latitude: court.latitude, longitude: court.longitude)
        mapView.setRegion(MKCoordinateRegion(center: coord, latitudinalMeters: 1000, longitudinalMeters: 1000), animated: false)
        let pin = MKPointAnnotation()
        pin.coordinate = coord
        pin.title = court.name
        mapView.addAnnotation(pin)
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        bookButton.addTarget(self, action: #selector(bookNowTapped), for: .touchUpInside)
    }

    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func favoriteTapped() {
        let isFav = favoriteButton.tintColor == .systemRed
        favoriteButton.setImage(UIImage(systemName: isFav ? "heart" : "heart.fill"), for: .normal)
        favoriteButton.tintColor = isFav ? .black : .systemRed
    }

    @objc private func bookNowTapped() {
        if AppStore.shared.currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController else { return }
            
            loginVC.onLoginSuccess = { [weak self, weak loginVC] in
                loginVC?.dismiss(animated: true) {
                    self?.navigateToBooking()
                }
            }
            
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
            return
        }

        navigateToBooking()
    }

    private func navigateToBooking() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewCourtBookingVC")
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            present(vc, animated: true)
        }
    }

}

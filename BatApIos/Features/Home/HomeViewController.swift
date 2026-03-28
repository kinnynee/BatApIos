import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var bellButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    private let store = AppStore.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        updateGreeting()
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateGreeting()
    }

    // MARK: - Actions
    @objc private func searchTextChanged(_ textField: UITextField) {
        // Mock filtering logic
        print("Searching for: \(textField.text ?? "")")
    }

    @IBAction func bellTapped(_ sender: Any) {
        let bookingsViewController = MyBookingsViewController()
        if let navigationController {
            navigationController.pushViewController(bookingsViewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: bookingsViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }

    private func updateGreeting() {
        let username = store.currentUser?.username ?? "Bạn"
        nameLabel.text = "\(username) 👋"
    }
}

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var languageObserver: NSObjectProtocol?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
        observeLanguageChanges()
        applyLocalizationIfNeeded()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if let languageObserver {
            NotificationCenter.default.removeObserver(languageObserver)
            self.languageObserver = nil
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

    private func observeLanguageChanges() {
        languageObserver = NotificationCenter.default.addObserver(
            forName: AppLocalization.languageDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyLocalizationIfNeeded()
        }
    }

    private func applyLocalizationIfNeeded() {
        guard let rootViewController = window?.rootViewController else { return }
        applyLocalization(to: rootViewController)
    }

    private func applyLocalization(to viewController: UIViewController) {
        if let tabBarController = viewController as? UITabBarController {
            updateTabBarTitles(for: tabBarController)
            tabBarController.viewControllers?.forEach { applyLocalization(to: $0) }
        }

        if let navigationController = viewController as? UINavigationController {
            navigationController.viewControllers.forEach { applyLocalization(to: $0) }
        }

        viewController.children.forEach { applyLocalization(to: $0) }
        if let presented = viewController.presentedViewController {
            applyLocalization(to: presented)
        }
    }

    private func updateTabBarTitles(for tabBarController: UITabBarController) {
        tabBarController.viewControllers?.enumerated().forEach { index, controller in
            let title = AppLocalization.tabBarTitle(for: index)
            guard title.isEmpty == false else { return }
            controller.tabBarItem.title = title
        }
    }
}

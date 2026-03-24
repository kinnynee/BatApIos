
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = makeInitialViewController(from: storyboard)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


    private func makeInitialViewController(from storyboard: UIStoryboard) -> UIViewController {
        guard let currentUser = AppMockStore.shared.currentUser else {
            return storyboard.instantiateViewController(withIdentifier: "LoginVC")
        }

        switch currentUser.role {
        case .admin:
            return storyboard.instantiateViewController(withIdentifier: "AdminDashboardVC")
        case .staff:
            return storyboard.instantiateViewController(withIdentifier: "StaffCheckInVC")
        case .user:
            return storyboard.instantiateViewController(withIdentifier: "MainTabBarVC")
        }
    }
}

import UIKit
import FirebaseCore
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
#if DEBUG
        if let options = FirebaseApp.app()?.options {
            print("[Firebase] projectID=\(options.projectID ?? "nil"), appID=\(options.googleAppID), gcmSenderID=\(options.gcmSenderID ?? "nil")")
        } else {
            print("[Firebase] FirebaseApp chưa được cấu hình đúng cách")
        }

        let db = Firestore.firestore()
        db.collection("__health_check").document("ping").getDocument { snap, error in
            if let error = error {
                print("[Firestore] Lỗi kết nối: \(error.localizedDescription)")
            } else {
                print("[Firestore] Kết nối thành công (getDocument)")
            }
        }
#endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

}

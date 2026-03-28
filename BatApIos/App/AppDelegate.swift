import UIKit
import FirebaseCore
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

#if DEBUG
        logFirebaseConfiguration()
        runFirestoreHealthCheck()
#endif

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }

#if DEBUG
    private func logFirebaseConfiguration() {
        guard let options = FirebaseApp.app()?.options else {
            print("[Firebase][Config] FirebaseApp chưa được cấu hình đúng cách")
            return
        }

        let bundleID = Bundle.main.bundleIdentifier ?? "nil"
        let bundleMatches = bundleID == options.bundleID

        print("[Firebase][Config] projectID=\(options.projectID ?? "nil")")
        print("[Firebase][Config] appID=\(options.googleAppID)")
        print("[Firebase][Config] gcmSenderID=\(options.gcmSenderID)")
        print("[Firebase][Config] plistBundleID=\(options.bundleID)")
        print("[Firebase][Config] runtimeBundleID=\(bundleID)")
        print("[Firebase][Config] bundleIDMatch=\(bundleMatches)")
    }

    private func runFirestoreHealthCheck() {
        let db = Firestore.firestore()
        let settings = db.settings

        print("[Firestore][Config] host=\(settings.host)")
        print("[Firestore][Config] sslEnabled=\(settings.isSSLEnabled)")
        print("[Firestore][Config] persistenceEnabled=\(settings.isPersistenceEnabled)")
        print("[Firestore][HealthCheck] Đang kiểm tra document __health_check/ping ...")

        db.collection("__health_check").document("ping").getDocument { snapshot, error in
            if let error {
                let nsError = error as NSError
                print("[Firestore][HealthCheck] Kết nối thất bại")
                print("[Firestore][HealthCheck] domain=\(nsError.domain)")
                print("[Firestore][HealthCheck] code=\(nsError.code)")
                print("[Firestore][HealthCheck] message=\(error.localizedDescription)")
                return
            }

            let exists = snapshot?.exists ?? false
            let path = snapshot?.reference.path ?? "__health_check/ping"
            let payload = snapshot?.data() ?? [:]

            print("[Firestore][HealthCheck] Kết nối thành công")
            print("[Firestore][HealthCheck] documentPath=\(path)")
            print("[Firestore][HealthCheck] documentExists=\(exists)")
            print("[Firestore][HealthCheck] payload=\(payload)")
        }
    }
#endif
}

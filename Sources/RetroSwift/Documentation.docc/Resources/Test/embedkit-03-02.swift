import UIKit
import CardholderKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let proxy: AppDelegateProxy

    var window: UIWindow? {
        get { proxy.window }
        set { proxy.window = newValue }
    }

    override init() {
        proxy = AppDelegateProxy()
        super.init()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        proxy.application(application, supportedInterfaceOrientationsFor: window)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return proxy.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        proxy.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        proxy.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}

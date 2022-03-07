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
}

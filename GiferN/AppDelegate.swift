import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        let mainViewController = FeedController()
        navigationController.viewControllers = [mainViewController]
        window!.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}


import UIKit
import TVServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName(TVTopShelfItemsDidChangeNotification, object: nil)
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        print("Application launched with URL: \(url)")

        guard let appVC = window?.rootViewController as? AppViewController else { return false }

        let appID = url.pathComponents?.last
        appVC.openShowWithID(appID)

        return true
    }
}


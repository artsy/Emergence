import UIKit
import TVServices

import Keys
import ARAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().postNotificationName(TVTopShelfItemsDidChangeNotification, object: nil)

        let keys = EmergenceKeys()
        #if DEBUG
            let segmentKey = keys.segmentDevWriteKey()
        #else
            let segmentKey = keys.segmentProductionWriteKey()
        #endif

        ARAnalytics.setupWithAnalytics([ARSegmentioWriteKey: segmentKey])
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String: AnyObject]) -> Bool {

        // When someone clicks on a top shelf item
        guard let appVC = window?.rootViewController as? AppViewController else { return false }
        guard let showID = url.pathComponents?.last else { return false }
        appVC.openShowWithID(showID)

        ARAnalytics.event("tapped featured shows", withProperties: ["partner_show_id": showID])
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        ARAnalytics.startTimingEvent("app session time")
    }

    func applicationWillResignActive(application: UIApplication) {
        ARAnalytics.finishTimingEvent("app session time")
    }
}

import UIKit
import TVServices

import Keys
import ARAnalytics
import GameController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(TVTopShelfItemsDidChangeNotification, object: nil)
        center.addObserver(self, selector:"controllerDidConnect:", name:GCControllerDidConnectNotification, object:nil)

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

    // So, what's going on here ey?
    // Well, we want to grab the install shot for a show that someone's about to click
    // on before they know they are going to click, the best way to guess that
    // is to see when they've stopped.
    //
    // So we send out a notification whenever the user has stopped scrolling, 
    // which the ShowOverviewVC can use to precache the install shot.

    var remote: GCMicroGamepad!
    func controllerDidConnect(notification: NSNotification) {
        guard let controller = notification.object as? GCController else { return }
        guard let micropad = controller.microGamepad else {
            return }
        remote = micropad
        remote.dpad.valueChangedHandler = { pad, x, y in
            if x == 0 && y == 0 {
                NSNotificationCenter.defaultCenter().postNotificationName("stopped scroll", object: nil)
            }
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        ARAnalytics.startTimingEvent("app session time")
    }

    func applicationWillResignActive(application: UIApplication) {
        ARAnalytics.finishTimingEvent("app session time")
    }
}

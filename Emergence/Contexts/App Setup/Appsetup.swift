import UIKit

/// Provides Global App Setup settings that can be accessed by
/// `AppSetup.sharedState`

class AppSetup {

    lazy var useStaging = false
    var isTesting = false

    class var sharedState : AppSetup {
        struct Static {
            static let instance = AppSetup()
        }
        return Static.instance
    }

    init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        useStaging = defaults.boolForKey("EmergenceUseStaging")

        if let _: AnyClass = NSClassFromString("XCTest") { isTesting = true }
    }
}

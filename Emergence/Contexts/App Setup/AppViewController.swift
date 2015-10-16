import Artsy_Authentication
import Keys
import UIKit
import Moya
import Alamofire

class AppViewController: UINavigationController {
    let context: AppContext = {
        let keys = EmergenceKeys()
        let network = ArtsyProvider<ArtsyAPI>()
        let auth = ArtsyAuthentication(clientID: keys.artsyAPIClientKey(), clientSecret: keys.artsyAPIClientSecret())

        return AppContext(network:network, auth:auth)
    }()

    func openShowWithID(showID: String?) {
        func topVCIsAuth() -> Bool {
            guard let topVC = self.topViewController else { return true }
            return topVC.isKindOfClass(AuthViewController) == false
        }

        guard let id = showID else { return }

        auth { success in
            // Did auth fail? try again in a sec
            if success == false {
                return delay(1, closure: { self.openShowWithID(showID) })
            }

            // Otherwise, try open it
            let info = ArtsyAPI.ShowInfo(showID: id)
            self.context.network.request(info).mapSuccessfulHTTPToObject(Show).subscribe { event in
                guard let show = event.element else { return }
                
                delayWhile(1, check: topVCIsAuth, closure: {
                    self.presentShowViewControllerForShow(show)
                })
            }
        }
    }

    func presentShowViewControllerForShow(show: Show) {
        guard let showVC = self.storyboard?.instantiateViewControllerWithIdentifier("show") as? ShowViewController else { return }
        showVC.show = show
        self.pushViewController(showVC, animated: true)
    }

    func auth(completion: (success: Bool) -> () ) {
        if context.network.authToken.isValid {
            completion(success: true)
        } else {
            context.auth.getWeekLongXAppTrialToken { token, error in
                if let token = token {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    saveToken(defaults, token:token)
                    self.context.network.authToken = XAppToken(defaults: defaults)
                }
                dispatch_async( dispatch_get_main_queue()) { completion(success: token != nil) }
            }
        }
    }
}



func saveToken(defaults: NSUserDefaults, token:ArtsyToken) {
    defaults.setObject(token.token, forKey: XAppToken.DefaultsKeys.TokenKey.rawValue)
    defaults.setObject(token.expirationDate, forKey: XAppToken.DefaultsKeys.TokenExpiry.rawValue)
    defaults.synchronize()
}

// Allow other controllers to look through the heirarchy for this

extension UIViewController {
    var appViewController: AppViewController? {
        guard let appVC = self.navigationController as? AppViewController else { return nil }
        return appVC
    }
}
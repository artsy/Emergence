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

    func auth(completion: () -> () ) {
        if self.context.network.authToken.isValid {
            completion()
        } else {
            print("Authenticating")
            context.auth.getWeekLongXAppTrialToken { (token, error) -> Void in

                print("Authenticated")
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(token.token, forKey: XAppToken.DefaultsKeys.TokenKey.rawValue)
                defaults.setObject(token.expirationDate, forKey: XAppToken.DefaultsKeys.TokenExpiry.rawValue)

                self.context.network.authToken = XAppToken(defaults: defaults)
                completion()
            }

        }
    }
}

// Allow other controllers to look through the heirarchy for this

extension UIViewController {
    var appViewController: AppViewController? {
        if let appVC = self.navigationController where appVC.isKindOfClass(AppViewController) {
            // How do I get rid of this warning?
            return appVC as! AppViewController;
        } else {
            return nil
        }
    }
}
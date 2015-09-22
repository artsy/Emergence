import Artsy_Authentication
import Keys
import UIKit

class AppViewController: UINavigationController {
    let context: AppContext = {
        let keys = EmergenceKeys()
        let network = ArtsyDrive(token: "")
        let auth = ArtsyAuthentication(clientID: keys.artsyAPIClientKey(), clientSecret: keys.artsyAPIClientSecret())
        return AppContext(network:network, auth:auth)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context.auth.getWeekLongXAppTrialToken { (token, error) -> Void in
            print("got \(token)")
            self.context.network.authToken = token.token
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
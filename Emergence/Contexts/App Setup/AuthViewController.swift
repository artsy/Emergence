import UIKit

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

        let network = appVC.context.network
        appVC.auth {
            network.enter { _ in
                self.performSegueWithIdentifier("show", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

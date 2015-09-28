import UIKit

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

        appVC.auth {
            self.performSegueWithIdentifier("show", sender: self)
        }

    }

}

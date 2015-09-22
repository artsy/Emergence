import UIKit
import RxHyperdrive

class ShowViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

        let network = appVC.context.network
        if let shows = network.root.transitions["show"] {
            let attributes = ["id": "4ea19ee97bab1a0001001908"]
            network.request(shows, parameters: attributes).subscribeNext { representor in
                print(representor)
            }
        }

    }
}

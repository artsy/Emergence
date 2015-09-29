import UIKit

class ShowLocationsViewController: UIViewController {
    var location: Location!

    override func viewDidLoad() {


        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

        let network = appVC.context.network

        let showInfo = ArtsyAPI.UpcomingShowsNearLocation(lat: "", long: "")
        network.request(showInfo).subscribe(next: { showObject in
                print(showObject)

            }, error: { error in
                print("ERROROR \(error)")
            }, completed: nil, disposed: nil)

    }

}


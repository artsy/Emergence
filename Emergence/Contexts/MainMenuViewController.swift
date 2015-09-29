import UIKit

class MainMenuViewController: UIViewController {
    var locationsHost: LocationsHost!
    var currentLocation: Location?

    var locationNames = ["new-york", "london", "paris"]

    override func viewDidLoad() {
        super.viewDidLoad()

        locationsHost = LocationsHost()
    }

    @IBAction func knownLocationTapped(sender: UIButton) {
        let locationName = locationNames[sender.tag]
        currentLocation = locationsHost[locationName]

        self.performSegueWithIdentifier("show_location", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let locationsVC = segue.destinationViewController as? ShowLocationsViewController {
            locationsVC.location = currentLocation
        }
    }

}

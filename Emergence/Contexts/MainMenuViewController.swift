import UIKit

/// Shows the featured shows along the top as a collectionview
/// then has a sectioned collectionview for each location

class MainMenuViewController: UIViewController {
    var locationsHost: LocationsHost!

    var featuredShows: [Show]!
    var featureShowsPresentor: FeaturedShowsPresentor!
    @IBOutlet weak var featuredShowsCollectionView: UICollectionView!

    var locationNames = ["new-york", "london", "paris"]

    override func viewDidLoad() {
        super.viewDidLoad()

        featureShowsPresentor = FeaturedShowsPresentor(shows: featuredShows, collectionView: featuredShowsCollectionView)
        locationsHost = LocationsHost()
    }
}

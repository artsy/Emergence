import UIKit

// OK, so. This is based on CollectionViewContainerViewController 
// from the UIKitCatalogue example code from Apple.
// The technique is to use a collectionview which hosts another collectionview

class ShowsOverviewViewController: UICollectionViewController {

    private static let minimumEdgePadding = CGFloat(90.0)
    private var emitters:[ShowEmitter]!
    private let locationsHost = LocationsHost()!
    var cachedShows:[Show] = []
    private var currentShow: Show?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appVC = self.appViewController else { return print("you need an app VC") }

        guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        collectionView.contentInset.top = ShowsOverviewViewController.minimumEdgePadding - layout.sectionInset.top
        collectionView.contentInset.bottom = ShowsOverviewViewController.minimumEdgePadding - layout.sectionInset.bottom

        let network = appVC.context.network

        // Create an emitter for grabbing our Featured Shows
        // if the cache took longer than the slideshow, get it

        let featuredEmitter = FeaturedShowEmitter(title: "Featured Shows", initialShows:cachedShows, network: network)
        if cachedShows.isEmpty { featuredEmitter.getShows() }

        let otherEmitters:[ShowEmitter] = locationsHost.featured.map { locationID in
            return LocationBasedShowEmitter(location: locationsHost[locationID]!, network: network)
        }

        let featured:[ShowEmitter] = [featuredEmitter]
        emitters = featured + otherEmitters
        collectionView.reloadData()

        // Get the above the fold content
        requestShowsAtIndex(1)
    }

    func requestShowsAtIndex(index: Int) {

        // extra index for the FeaturedShowEmitter
        if index < emitters.count - 2 {
            let anEmitter = emitters[index]
            guard let emitter = anEmitter as? LocationBasedShowEmitter else { return }
            if emitter.numberOfShows != 0 { return }

            emitter.getShows()
        }
    }

    func showTapped(show: Show) {
        // can't pass the show as a sender - it has to be an object
        currentShow = show
        performSegueWithIdentifier("show", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let locationsVC = segue.destinationViewController as? ShowViewController {
            locationsVC.show = currentShow
        }
    }

}



// All the collection view gubbins

extension ShowsOverviewViewController {

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return emitters.count
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        return collectionView.dequeueReusableCellWithReuseIdentifier(ShowSetCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ShowSetCollectionViewCell else { fatalError("Expected to display a `ShowSetCollectionViewCell`.") }

        let emitter = emitters[indexPath.section]
        cell.configureWithEmitter(emitter)
    }

    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        // We don't want this collectionView's cells to become focused. 
        // Instead the `UICollectionView` contained in the cell should become focused.

        if indexPath.section > 1 {
            // this handles multiple calls fine
            requestShowsAtIndex(indexPath.section + 1)
        }
        return false
    }

}

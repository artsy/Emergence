import UIKit
import SDWebImage

// OK, so. This is based on CollectionViewContainerViewController 
// from the UIKitCatalogue example code from Apple.
// The technique is to use a collectionview which hosts another collectionview

class ShowsOverviewViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private static let minimumEdgePadding = CGFloat(90.0)
    private var emitters:[ShowEmitter]!
    private let locationsHost = LocationsHost()!
    var cachedShows:[Show] = []

    private var currentShows: [Show]?
    private var currentIndex: Int?

    private let leadingEdgeImageCache = SDWebImagePrefetcher()
    private let currentRowImageCache = SDWebImagePrefetcher()

    var scrolling = false
    var lastOffset = CGPointZero
    var lastOffsetCapture:NSTimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appVC = self.appViewController else { return print("you need an app VC") }
        guard let collectionView = collectionView else { return }

//        appVC.openShowWithID("joshua-liner-gallery-libby-black-theres-no-place-like-home")
//        appVC.presentShowViewControllerForShow(Show.stubbedShow())

        let network = appVC.context.network

        // Create an emitter for grabbing our Featured Shows
        // if the cache took longer than the slideshow, get it

        let featuredEmitter = FeaturedShowEmitter(title: "Featured Shows", initialShows: cachedShows, network: network)
        if cachedShows.isEmpty { featuredEmitter.getShows() }

        let otherEmitters:[ShowEmitter] = locationsHost.featured.map { locationID in
            let locationEmitter = LocationBasedShowEmitter(location: locationsHost[locationID]!, network: network)
            locationEmitter.onUpdate({[weak locationEmitter] shows in
                if let locationEmitter = locationEmitter where shows.count == 0 {
                    self.removeEmitterAndSection(locationEmitter)
                }
            })
            return locationEmitter
        }

        let featured:[ShowEmitter] = [featuredEmitter]
        emitters = featured + otherEmitters
        collectionView.reloadData()

        // Get the above the fold content
        requestShowsAtIndex(1)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard let nav = navigationController else { return }
        nav.viewControllers = nav.viewControllers.filter({ $0.isKindOfClass(AuthViewController) == false })
    }

    func removeEmitterAndSection(emitter: ShowEmitter) {
        guard let emitterIndex = emitters.indexOf(emitter.isEqualTo) else {
            return
        }
        
        emitters.removeAtIndex(emitterIndex)
        collectionView?.deleteSections(NSIndexSet(index: emitterIndex))
    }
    
    func locationEmitterAtIndex(index: Int) -> LocationBasedShowEmitter? {

        // ignore the FeaturedShowEmitter
        if index == 0 || index > emitters.count - 1 { return nil }
        let anEmitter = emitters[index]
        guard let emitter = anEmitter as? LocationBasedShowEmitter else { return nil }
        return emitter
    }

    func requestShowsAtIndex(index: Int) {
        guard let emitter = locationEmitterAtIndex(index) else { return }
        emitter.getShows()
    }

    func precacheShowImagesAtIndex(index:Int) {
        guard let emitter = locationEmitterAtIndex(index) else { return }
        currentRowImageCache.cancelPrefetching()
        currentRowImageCache.prefetchURLs( emitter.imageURLsForShowsAtLocation() )
    }

    func showTapped(index: Int, shows: [Show]) {
        // can't pass the show as a sender - it has to be an object
        currentShows = shows
        currentIndex = index
        performSegueWithIdentifier("show", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        leadingEdgeImageCache.cancelPrefetching()
        currentRowImageCache.cancelPrefetching()

        if let showSetVC = segue.destinationViewController as? ShowSetViewController {
            showSetVC.shows = currentShows
            showSetVC.initialIndex = currentIndex
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

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "header", forIndexPath: indexPath)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section != 0  { return CGSizeZero }
        return CGSizeMake(view.bounds.width, 180)
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ShowSetCollectionViewCell else { fatalError("Expected to display a `ShowSetCollectionViewCell`.") }

        let emitter = emitters[indexPath.section]
        cell.configureWithEmitter(emitter)
    }

    // The crux of the problem is explained in ShowSetCollectionViewController.
    // However it's interesting to note that scrolling is determined by the speed of the scroll
    // Using this instead of a bool for scrolling basically erased most reload flickers.

    func pixelsPerSecondConsideredFast() -> CGFloat {
        return 0.5
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        scrolling = true

        let currentOffset = scrollView.contentOffset;
        let currentTime:NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()

        let timeDiff = currentTime - Double(lastOffsetCapture)
        if (timeDiff > 0.1) {

            let distance = currentOffset.y - lastOffset.y
            let scrollSpeedPX = (distance * 10) / 1000
            let scrollSpeed = abs(scrollSpeedPX)

            scrolling = scrollSpeed > pixelsPerSecondConsideredFast()
            lastOffset = currentOffset;
            lastOffsetCapture = currentTime
        }
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrolling = false
    }
    

    // MARK: Focus

    override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        // We don't want this collectionView's cells to become focused. 
        // Instead the `UICollectionView` contained in the cell should become focused.

        let anyEmitter = emitters[indexPath.section]
        guard let _ = anyEmitter as? LocationBasedShowEmitter else { return false }

        // these handle multiple calls fine
        requestShowsAtIndex(indexPath.section)
        requestShowsAtIndex(indexPath.section + 1)

        return false
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        let sameParent = context.previouslyFocusedView?.superview == context.nextFocusedView?.superview
        if sameParent { return }

        // On clicking into a show, we get one last "things have changed message"
        if let _ = context.nextFocusedView as? ImageCollectionViewCell { return }

        guard let showCell = context.nextFocusedView as? ShowCollectionViewCell else { return print("Cell needs to be ShowCollectionViewCell") }
        guard let locationCell = showCell.superview?.superview?.superview as? ShowSetCollectionViewCell else { return print("View Heriarchy has changed for the ShowSetCollectionViewCell") }

        if let indexPath = collectionView?.indexPathForCell(locationCell) {
            precacheShowImagesAtIndex(indexPath.section)
        }
    }
}

class ShowsOverviewHeaderReuseView : UICollectionReusableView {

    @IBOutlet var aboutButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        aboutButton.layer.borderColor = UIColor.artsyGrayMedium().CGColor
        aboutButton.layer.borderWidth = 1
    }
}

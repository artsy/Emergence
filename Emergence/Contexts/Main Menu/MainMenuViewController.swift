import UIKit

/// Shows the featured shows along the top as a collectionview
/// then has a sectioned collectionview for each location

class MainMenuViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    var featuredShows: [Show]!
    var featureShowsPresentor: FeaturedShowsPresentor!
    @IBOutlet weak var featuredShowsCollectionView: UICollectionView!

    var locationsPresentor: LocationShowsPresentor!
    @IBOutlet weak var locationShowsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        featuredShows = [Show.stubbedShow(), Show.stubbedShow()]

        featureShowsPresentor = FeaturedShowsPresentor(shows: featuredShows, collectionView: featuredShowsCollectionView)

        locationsPresentor = LocationShowsPresentor(collectionView: locationShowsCollectionView)
    }

    override var preferredFocusedView: UIView? {
        return featuredShowsCollectionView
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let show: Show
        if collectionView == featuredShowsCollectionView {
            show = featureShowsPresentor.showAtIndexPath(indexPath)
        } else {
            show = locationsPresentor.showAtIndexPath(indexPath)
        }

        print(show)
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
    {
        super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)

        guard let nextFocusedView = context.nextFocusedView else { return }

        coordinator.addCoordinatedAnimations({ [unowned self] in
            // Scroll to make sure we can see the selected object
            let bounds = nextFocusedView.convertRect(nextFocusedView.bounds, toView: self.scrollView)
            self.scrollView.scrollRectToVisible(bounds, animated: false)

        }, completion: nil)
    }

}

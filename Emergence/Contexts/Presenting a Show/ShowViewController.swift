import UIKit
import RxSwift
import Moya
import Gloss

class ShowViewController: UIViewController {
    var show: Show!

    var didForceFocusChange = true

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPartnerNameLabel: UILabel!
    @IBOutlet weak var showAusstellungsdauerLabel: UILabel!
    @IBOutlet weak var showLocationLabel: UILabel!

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!

    @IBOutlet weak var aboutTheShowLabel: UILabel!

    @IBOutlet weak var pressReleaseLabel: UILabel!
    @IBOutlet weak var pressReleaseTitle: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollChief: ShowScrollChief!


    var artworkDelegate: CollectionViewDelegate<Artwork>!
    var artworkDataSource: CollectionViewDataSource<Artwork>!
    var imageDelegate: CollectionViewDelegate<Image>!
    var imageDataSource: CollectionViewDataSource<Image>!

    override func viewDidLoad() {
        precondition(self.show != nil, "you need a show to load the view controller");
        precondition(self.appViewController != nil, "you need an app VC");

        super.viewDidLoad()
        print("Looking at \(show.id)")
        showDidLoad(show)

        guard let appVC = self.appViewController else {
            return print("you need an app VC")
        }

        let network = appVC.context.network
        let networker = ShowNetworkingModel(network: network, show: show)

        // Toggle for stubbing the data for the images/artworks
        let offline = true
        let imageData = offline ? networker.imageNetworkFakes : networker.imageNetworkRequest
        let artworkData = offline ? networker.artworkNetworkFakes : networker.artworkNetworkRequest

        imageDataSource = CollectionViewDataSource<Image>(imagesCollectionView, request: imageData, cellIdentifier: "image")
        imageDelegate = CollectionViewDelegate<Image>(datasource: imageDataSource, collectionView: imagesCollectionView)

        artworkDataSource = CollectionViewDataSource<Artwork>(artworkCollectionView, request: artworkData, cellIdentifier: "artwork")
        artworkDelegate = CollectionViewDelegate<Artwork>(datasource: artworkDataSource, collectionView: artworkCollectionView)

        self.scrollView.scrollEnabled = false
    }

    func showDidLoad(show: Show) {
        showTitleLabel.text = show.name
        showPartnerNameLabel.text = show.partner.name

        if let location:String = show.locationOneLiner {
            showLocationLabel.text = location
        } else {
            showLocationLabel.removeFromSuperview()
        }

        if let start = show.startDate, end = show.endDate {
            showAusstellungsdauerLabel.text = start.ausstellungsdauerToDate(end)
        } else {
            showAusstellungsdauerLabel.removeFromSuperview()
        }

        if let release = show.pressRelease {
            pressReleaseLabel.text = release
        } else {
            pressReleaseTitle.removeFromSuperview()
            pressReleaseLabel.removeFromSuperview()
        }

        aboutTheShowLabel.text = show.showDescription
    }

    override var preferredFocusedView: UIView? {
        return scrollChief.keyView
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let next = context.nextFocusedView else { return }

        // We want to move the images collectionview across to full screen after you scroll past the first index.

        if next.isDescendantOfView(imagesCollectionView) {
            guard let cell = context.nextFocusedView as? UICollectionViewCell else { return }
            let index = imagesCollectionView.indexPathForCell(cell)!.row
            let xOffset: CGFloat = index == 0 ? 660 : 0

            // No need to do it if it's already set up right
            if xOffset == imagesCollectionView.frame.origin.x { return }

            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.7, options: [.OverrideInheritedOptions], animations: {

                let originalFrame = self.imagesCollectionView.frame
                self.imagesCollectionView.frame = CGRectMake(xOffset, originalFrame.origin.y, self.view.bounds.width - xOffset, originalFrame.height)

            }, completion: nil)
        }
    }

    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        // We want to avoid jumping between multiple pages

        if didForceFocusChange == false {
            // Allow moving between collectionview cells in the same parent
            let sameParent = context.previouslyFocusedView?.superview == context.nextFocusedView?.superview
            return sameParent
        }

        didForceFocusChange = false
        return context.nextFocusedView == scrollChief.keyView
    }
}

// Keeping these around in here for now, if they get more complex they can go somewhere else

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}
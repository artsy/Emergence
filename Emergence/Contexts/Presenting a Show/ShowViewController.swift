import UIKit
import RxSwift
import Moya
import Gloss
import ARAnalytics
import SDWebImage


class ShowViewController: UIViewController, ShowItemTapped {
    var show: Show!

    var didForceFocusChange = true

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPartnerNameLabel: UILabel!
    @IBOutlet weak var showAusstellungsdauerLabel: UILabel!
    @IBOutlet weak var showLocationLabel: UILabel!

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!

    @IBOutlet weak var aboutTheShowTitle: UILabel!
    @IBOutlet weak var aboutTheShowLabel: HalfIntrinsicHeightSerifLabel!

    @IBOutlet weak var pressReleaseLabel: HalfIntrinsicHeightSerifLabel!
    @IBOutlet weak var pressReleaseTitle: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollChief: ShowScrollChief!

    var networker: ShowNetworkingModel!
    var artworkDelegate: CollectionViewDelegate<Artwork>!
    var artworkDataSource: CollectionViewDataSource<Artwork>!
    var imageDelegate: CollectionViewDelegate<Image>!
    var imageDataSource: CollectionViewDataSource<Image>!

    var imageRequest: Observable<[Image]>!
    var artworkRequest: Observable<[Artwork]>!
    var imageCache = SDWebImagePrefetcher()

    override func viewDidLoad() {
        precondition(self.show != nil, "you need a show to load the view controller");
        precondition(self.appViewController != nil, "you need an app VC");

        super.viewDidLoad()
        showDidLoad(show)

        guard let appVC = self.appViewController else {
            return print("you need an app VC")
        }

        let network = appVC.context.network
        networker = ShowNetworkingModel(network: network, show: show)

        // Toggle to imageNetworkFakes for stubbing the data 
        // for the images/artworks, mainly for
        // when I'm on a coach/train/plane

        imageRequest = networker.imageNetworkRequest
        artworkRequest = networker.artworkNetworkRequest

        imageDataSource = CollectionViewDataSource<Image>(imagesCollectionView, cellIdentifier: "image", show:show, cache:imageCache)
        imageDataSource.subscribeToRequest(imageRequest)
        imageDelegate = CollectionViewDelegate<Image>(datasource: imageDataSource, collectionView: imagesCollectionView, show:show, delegate: nil)

        artworkDataSource = CollectionViewDataSource<Artwork>(artworkCollectionView, cellIdentifier: "artwork", show:show, cache:imageCache)
        artworkDataSource.subscribeToRequest(artworkRequest)
        artworkDelegate = CollectionViewDelegate<Artwork>(datasource: artworkDataSource, collectionView: artworkCollectionView, show:show, delegate: self)
        artworkDelegate.internalPadding = 150

        self.scrollView.scrollEnabled = false
        ARAnalytics.event("partner show view", withProperties:[
            "partner_show_id": show.id,
            "partner_id": show.partner.id,
            "profile_id": show.partner.profileID ?? "",
            "fair_id":""
        ])
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        imageCache.cancelPrefetching()
    }

    let longFormlineSpacing = 15
    let longFormIntrinsicDivider:CGFloat = 4.25

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

        if let description = show.showDescription where description.isNotEmpty {
            aboutTheShowLabel.intrinsicMultiplier = longFormIntrinsicDivider
            aboutTheShowLabel.attributedText = lineHeightAttributedStringForString(description)
        } else {
            aboutTheShowLabel.removeFromSuperview()
            aboutTheShowTitle.removeFromSuperview()
        }

        if let release = show.pressRelease where release.isNotEmpty {
            pressReleaseLabel.intrinsicMultiplier = longFormIntrinsicDivider
            pressReleaseLabel.attributedText = lineHeightAttributedStringForString(release)
        } else {
            pressReleaseTitle.removeFromSuperview()
            pressReleaseLabel.removeFromSuperview()
        }

    }

    func lineHeightAttributedStringForString(string: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 15
        attrString.addAttribute(NSParagraphStyleAttributeName, value:style, range:NSRange(location: 0, length: string.characters.count))
        return attrString
    }

    // Focus is complicated on this view, you can get the details in the ShowScrollChief

    override var preferredFocusedView: UIView? {
        return scrollChief.keyView
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        guard let next = context.nextFocusedView else { return }

        // We want to move the images collectionview across to full screen after you scroll past the first index.
        guard next.isDescendantOfView(imagesCollectionView) else { return }

        guard let cell = context.nextFocusedView as? UICollectionViewCell else { return }
        let index = imagesCollectionView.indexPathForCell(cell)!.row
        let movingBack = index == 0
        let xOffset: CGFloat = movingBack ? 660 : 0

        // No need to do it if it's already set up right
        if xOffset == imagesCollectionView.frame.origin.x { return }

        let delay = movingBack ? 0.6 : 0
        let originalFrame = self.imagesCollectionView.frame
        let metadataAlpha:CGFloat = movingBack ? 1 : 0

        UIView.animateWithDuration(0.4, delay: delay, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.7, options: [.OverrideInheritedOptions], animations: {

            self.imagesCollectionView.frame = CGRectMake(xOffset, originalFrame.origin.y, self.view.bounds.width, originalFrame.height)
            let metadata = [self.showTitleLabel, self.showPartnerNameLabel, self.showAusstellungsdauerLabel, self.showLocationLabel]
            metadata.forEach({ $0.alpha = metadataAlpha })

        }, completion:nil)
    }

    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        // We want to avoid jumping between multiple pages

        if didForceFocusChange == false {

            if let nextView = context.nextFocusedView where nextView.isDescendantOfView(artworkCollectionView) {
                // It's an artwork view, let's paginate
                artworkRequest = networker.artworkNetworkRequest
                artworkDataSource.subscribeToRequest(artworkRequest)
            }

            // Allow moving between collectionview cells in the same parent
            let sameParent = context.previouslyFocusedView?.superview == context.nextFocusedView?.superview
            return sameParent
        }

        didForceFocusChange = false
        return context.nextFocusedView == scrollChief.keyView
    }

    // Can't pass structs through performSegue
    var selectedArtwork: Artwork!

    func didTapArtwork(item: Artwork) {
        selectedArtwork = item
        performSegueWithIdentifier("artwork", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let artworkSetVC = segue.destinationViewController as? ArtworkSetViewController else { return }

        artworkSetVC.artworks = artworkDataSource.items
        artworkSetVC.initialIndex = artworkSetVC.artworks.indexOf({ $0.id == selectedArtwork.id })
    }
}

// Keeping this around in here for now, if it gets more complex it can go somewhere else
class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!

    override func prepareForReuse() {
        image.image = nil
    }
}
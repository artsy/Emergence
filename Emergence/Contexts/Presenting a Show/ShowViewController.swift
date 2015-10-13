import UIKit
import RxSwift
import Moya
import Gloss

class ShowViewController: UIViewController {
    var index = -1
    var show: Show!

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPartnerNameLabel: UILabel!
    @IBOutlet weak var showAusstellungsdauerLabel: UILabel!
    @IBOutlet weak var showLocationLabel: UILabel!

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!

    @IBOutlet weak var scrollView: UIScrollView!

    var artworkDelegate: CollectionViewDelegate<Artwork>!
    var artworkDataSource: CollectionViewDataSource<Artwork>!
    var imageDelegate: CollectionViewDelegate<Image>!
    var imageDataSource: CollectionViewDataSource<Image>!

    override func viewDidLoad() {
        precondition(self.show != nil, "you need a show to load the view controller");
        precondition(self.appViewController != nil, "you need an app VC");

        super.viewDidLoad()
        showDidLoad(show)

        guard let appVC = self.appViewController else {
            return print("you need an app VC")
        }

        let network = appVC.context.network

        // Setup the Image pager
        let showImages = ArtsyAPI.ImagesForShow(showID: show.id)
        let imageNetworking = network.request(showImages).mapSuccessfulHTTPToObjectArray(Image)
        imageDataSource = CollectionViewDataSource<Image>(imagesCollectionView, request: imageNetworking, cellIdentifier: "image")
        imageDelegate = CollectionViewDelegate<Image>(datasource: imageDataSource, collectionView: imagesCollectionView)

        // Setup the Artwork pager
        let showArtworks = ArtsyAPI.ArtworksForShow(partnerID: show.partner.id, showID: show.id)
        let artworkNetworking = network.request(showArtworks).mapSuccessfulHTTPToObjectArray(Artwork)
        artworkDataSource = CollectionViewDataSource<Artwork>(artworkCollectionView, request: artworkNetworking, cellIdentifier: "artwork")
        artworkDelegate = CollectionViewDelegate<Artwork>(datasource: artworkDataSource, collectionView: artworkCollectionView)
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
    }

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        guard let next = context.nextFocusedView else {
            return print("Next view was empty in didUpdateFocusInContext")
        }

        // Super simple pagination for now, will build out as things get more complex

        let yOffset: CGFloat
        if next.isDescendantOfView(imagesCollectionView) { yOffset = 0 }
        else if next.isDescendantOfView(artworkCollectionView) { yOffset = 1080 }
        else { return }

        coordinator.addCoordinatedAnimations({
            self.scrollView.contentOffset = CGPoint(x: 0, y: yOffset)
        }, completion: nil)
    }
}

// Keeping these around in here for now, if they get more complex they can go somewhere else

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}

class ArtworkCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
}

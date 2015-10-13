import UIKit
import RxSwift
import Moya
import Gloss
import ARCollectionViewMasonryLayout
import SDWebImage

class ShowViewController: UIViewController {
    var index = -1
    var show: Show!

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPartnerNameLabel: UILabel!
    @IBOutlet weak var showAusstellungsdauerLabel: UILabel!
    @IBOutlet weak var showLocationLabel: UILabel!

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!

    var imageDelegate: CollectionViewDelegate<Image>!
    var artworkDelegate: ArtworkDelegate!
    var artworkVVM: CollectionViewDataSource<Artwork>!
    var imageVVM: CollectionViewDataSource<Image>!

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
        imageVVM = CollectionViewDataSource<Image>(imagesCollectionView, request: imageNetworking, cellIdentifier: "image")
        imageDelegate = CollectionViewDelegate<Image>(datasource: imageVVM, collectionView: imagesCollectionView)

//        // Setup the Artwork pager
//        let showArtworks = ArtsyAPI.ArtworksForShow(partnerID: show.partner.id, showID: show.id)
//        let artworkNetworking = network.request(showArtworks).mapSuccessfulHTTPToObjectArray(Artwork)
//        artworkVVM = CollectionViewDataSource<Artwork>(artworkCollectionView, request: artworkNetworking)

//        artworkDelegate = ArtworkDelegate(datasource: artworkVVM)
//        artworkDelegate.setup(artworkCollectionView)
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
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
}


class CollectionViewDelegate <T>: NSObject, ARCollectionViewMasonryLayoutDelegate {

    let dimensionLength:CGFloat
    let artworkDataSource: CollectionViewDataSource<T>

    init(datasource: CollectionViewDataSource<T>, collectionView: UICollectionView) {
        artworkDataSource = datasource
        dimensionLength = collectionView.bounds.height

        super.init()

        let layout = ARCollectionViewMasonryLayout(direction: .Horizontal)
        layout.rank = 1
        layout.dimensionLength = dimensionLength
        layout.itemMargins = CGSize(width: 40, height: 0)

        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.setNeedsLayout()
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let item = artworkDataSource.itemForIndexPath(indexPath)

        guard let actualItem = item, image:Image = imageForItem(actualItem) else {
            // otherwise, ship a square
            return dimensionLength
        }

        if let ratio = image.aspectRatio {
            return dimensionLength * ratio
        }

        // Hrm is this right?
        let ratio = image.imageSize.height / image.imageSize.width
        return dimensionLength * ratio
    }

    func imageForItem(item:T) -> Image? {
        // If it's an artwork grab the default image
        if var artwork = item as? Artwork, let defaultImage = artwork.defaultImage, let actualImage = defaultImage as? Image {
            return actualImage

        } else if let actualImage = item as? Image {
        // otherwise it is an image
            return actualImage
        }

        return nil
    }

        func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

            guard let item = artworkDataSource.itemForIndexPath(indexPath) else { return }
            guard let image = imageForItem(item) else { return }

            if let cell = cell as? ImageCollectionViewCell, let url = image.bestAvailableThumbnailURL() {
                cell.image.sd_setImageWithURL(url)
            }


        }

}



class ArtworkDelegate: NSObject, ARCollectionViewMasonryLayoutDelegate {

    let dimensionLength:CGFloat = 630
    let artworkDataSource: CollectionViewDataSource<Artwork>

    init(datasource: CollectionViewDataSource<Artwork>) {
        artworkDataSource = datasource
    }

    func setup(collectionView: UICollectionView) {
        let layout = ARCollectionViewMasonryLayout(direction: .Horizontal)
        layout.rank = 1
        layout.dimensionLength = collectionView.bounds.height
        layout.itemMargins = CGSize(width: 40, height: 0)

        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.setNeedsLayout()
    }

    // Let's see if I get time for an artwork view

    //    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    //        let show = emitter.showAtIndexPath(indexPath)
    //        hostViewController.showTapped(show)
    //    }

//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        guard let cell = cell as? ShowCollectionViewCell else { fatalError("Expected to display a ShowCollectionViewCell") }

//        let artwork = artworkDataSource.itemForIndexPath(indexPath)
//        cell.configureWithShow(show)
//    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        var artwork = artworkDataSource.itemForIndexPath(indexPath)

        // No default image, so show a square?
        guard let image = artwork?.defaultImage as Imageable? else {
            return dimensionLength
        }

        if let ratio = image.aspectRatio {
            return dimensionLength * ratio
        }

        // Hrm is this right?
        let ratio = image.imageSize.height / image.imageSize.width
        return dimensionLength * ratio
    }
}

class CollectionViewDataSource <T>: NSObject, UICollectionViewDataSource {
    let collectionView: UICollectionView
    let cellIdentifier: String
    var items: [T]?

    init(_ collectionView: UICollectionView, request: Observable<[(T)]>, cellIdentifier: String) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        super.init()
        
        collectionView.dataSource = self
        request.subscribe(next: { items in
            self.items = items
            self.collectionView.reloadData()

        }, error: { error in
            print("ERROROR \(error)")

        }, completed: nil, disposed: nil)
    }

    func itemForIndexPath(path: NSIndexPath) -> T? {
        return items?[path.row]
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
    }

}

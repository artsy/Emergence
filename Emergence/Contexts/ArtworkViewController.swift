import UIKit
import ARAnalytics
import SDWebImage

class ArtworkViewController: UIViewController {
    var index: Int!
    var artwork: Artwork!

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkNameLabel: UILabel!
    @IBOutlet weak var artworkMediumLabel: UILabel!
    @IBOutlet weak var artworkDimensionsInchesLabel: UILabel!

    @IBOutlet weak var artworkDimensionsCMsLabel: UILabel!

    @IBOutlet var artworkPreviewImage: UIImageView!

    override func viewDidLoad() {
        artistNameLabel.text = artwork.oneLinerArtist()
        artworkNameLabel.attributedText = artwork.titleWithDate()
        artworkMediumLabel.text = artwork.medium
        artworkDimensionsInchesLabel.text = artwork.dimensionsInches
        artworkDimensionsCMsLabel.text = artwork.dimensionsCM

        /// OK, we want to re-use images as much as possible
        /// so that you're not staring at grey boxes.

        /// In this case we are grabbing the thumbnail, probably loaded
        /// in the ShowViewController and seeing if it's in the image cache, if it 
        /// is then we set the placeholder to be the existing image
        /// and then request a bigger image async.

        let showArtworksHeight:CGFloat = 620

        if let defaultImage = artwork.defaultImage, let actualImage = defaultImage as? Image {

            let height = artworkPreviewImage.bounds.height
            guard let fullThumbnailPath = actualImage.bestThumbnailWithHeight(height) else { return print("no thumbnail for artwork") }

            let manager = SDWebImageManager.sharedManager()
            if let previousThumbnail = actualImage.bestThumbnailWithHeight(showArtworksHeight) where manager.cachedImageExistsForURL(previousThumbnail) {
                let key = manager.cacheKeyForURL(previousThumbnail)
                let smallerInitialThumbnail = manager.imageCache.imageFromMemoryCacheForKey(key)

                artworkPreviewImage.sd_setImageWithURL(fullThumbnailPath, placeholderImage: smallerInitialThumbnail)
            } else {
                artworkPreviewImage.ar_setImage(actualImage, height: height)
            }
        }

        ARAnalytics.event("artwork view", withProperties: ["artwork_id": artwork.id, "fair":""])
    }
}

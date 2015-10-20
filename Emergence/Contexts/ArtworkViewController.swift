import UIKit

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

        if let defaultImage = artwork.defaultImage, let actualImage = defaultImage as? Image {
            artworkPreviewImage.ar_setImage(actualImage, height: artworkPreviewImage.bounds.height)
        }
    }
}

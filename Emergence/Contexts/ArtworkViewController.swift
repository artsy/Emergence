import UIKit

class ArtworkViewController: UIViewController {
    var index: Int!
    var artwork: Artwork!

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkNameLabel: UILabel!
    @IBOutlet weak var artworkMediumLabel: UILabel!
    @IBOutlet weak var artworkDimensionsInchesLabel: UILabel!

    @IBOutlet weak var artworkDimensionsCMsLabel: UILabel!

    override func viewDidLoad() {
        artistNameLabel.text = artwork.oneLinerArtist()
        artworkNameLabel.text = artwork.title
        artworkMediumLabel.text = artwork.medium
//        artworkDimensionsInchesLabel.text = artwork.
    }
}

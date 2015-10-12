import UIKit

/// Just a dumb presentation class

class ShowCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "ShowCollectionViewCell"

    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var showNameLabel: UILabel!
    @IBOutlet weak var ausstellungsdauerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    func configureWithShow(show:Show) {
        showNameLabel.text = show.name
        partnerNameLabel.text = show.partner.name

        if let thumbnailURL = show.bestAvailableThumbnailURL() {
            imageView.sd_setImageWithURL(thumbnailURL)
        } else {
            print("Could not find a thumbnail for \(show.name) - found \(show.imageVersions)")
        }

        if let start = show.startDate, end = show.endDate {
            ausstellungsdauerLabel.text = start.ausstellungsdauerToDate(end)
        } else {
            ausstellungsdauerLabel.text = ""
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false

        setLabelsAlpha(0)
    }

    func setLabelsAlpha(value: CGFloat) {
        partnerNameLabel.alpha = value
        showNameLabel.alpha = value
        ausstellungsdauerLabel.alpha = value
    }

    // MARK: UICollectionReusableView

    override func prepareForReuse() {
        super.prepareForReuse()
        setLabelsAlpha(0)
    }

    // MARK: UIFocusEnvironment

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        coordinator.addCoordinatedAnimations({ [unowned self] in
            self.setLabelsAlpha(self.focused ? 1 : 0)
        }, completion: nil)
    }

}

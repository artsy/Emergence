import UIKit

class ArtworkCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var image: UIImageView!

    // Tried this with AL and couldn't animate, so frames
    // Moves the text to stay left aligned with the focused image
    // and down a bit, cause it was just too close.

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        coordinator.addCoordinatedAnimations({ [unowned self] in

            let xOffset:CGFloat = self.focused ? -10 : 20
            let yOffset:CGFloat = self.focused ? 20 : -20

            let width = self.bounds.width - xOffset - 20
            var y = self.artistNameLabel.frame.origin.y + yOffset
            self.artistNameLabel.frame = CGRectMake(xOffset, y, width, 30)

            y = self.titleLabel.frame.origin.y + yOffset
            self.titleLabel.frame = CGRectMake(xOffset, y, width, 20)
        }) {}
    }
}

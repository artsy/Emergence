
import UIKit

class ARMotionImageView: UIImageView {

    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

        if context.nextFocusedView == self.superview {

        } else {

        }

        coordinator.addCoordinatedAnimations({ [unowned self] in

            }, completion: nil)
    }

}

import UIKit

class ShowScrollChief: NSObject {

    @IBOutlet weak var controller: ShowViewController!

    var index = 0 {
        didSet {
            controller.didForceFocusChange = true
            controller.setNeedsFocusUpdate()

            UIView.animateWithDuration(0.9, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.7, options:  [.OverrideInheritedOptions], animations: {
                self.scrollView.contentOffset = self.scrollPositionForCurrentView()

            }, completion: nil)
        }
    }

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!

    // TODO: Doesn't support arbitrary numbers of scrolls

    func views() -> [UIView] {
        return [imagesCollectionView, artworkCollectionView, view, view]
    }

    func scrollPositionForCurrentView() -> CGPoint {
        let offsets = [0, 1160, 2000, 2000, 2000, 2000, 2000]
        return CGPoint(x: 0, y: offsets[index])
    }

    @IBAction func gesturedUp(gesture:UISwipeGestureRecognizer) {
        index = max(index-1, 0)
    }

    @IBAction func gesturedDown(gesture:UISwipeGestureRecognizer) {
        index = min(index+1, views().count - 1)
    }

    var keyView: UIView {
        return views()[index]
    }
}

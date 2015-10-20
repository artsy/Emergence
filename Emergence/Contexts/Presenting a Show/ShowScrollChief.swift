import UIKit

/// Right, so, we don't want to use Apple's scrolling between sections
/// cause it's too fast, and we're paginating on a full page.

/// So there's this scroll chief whose job it is to migrate
/// the focus between different views, and different pages.

/// The name is yet another mobile team running joke, I'm always willing
/// to lose some abstract perfection for the sake of a good joke.

class ShowScrollChief: NSObject {

    @IBOutlet weak var controller: ShowViewController!

    /// Setting the current view index will animate us to that correct point.
    /// telling the controller it needs focus means it will ask us back who to focs on
    /// which it gets from keyView below

    var index = 0 {
        didSet {
            controller.didForceFocusChange = true
            controller.setNeedsFocusUpdate()

            UIView.animateWithDuration(0.9, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.8, options:  [.OverrideInheritedOptions, .AllowUserInteraction], animations: {
                self.scrollView.contentOffset = self.scrollPositionForCurrentView()

            }, completion: nil)
        }
    }

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var artworkCollectionView: UICollectionView!

    // At the top its the collection views, under that then we don't
    // select anything, so use the main view object as it has no interaction model
    func views() -> [UIView] {
        return [imagesCollectionView, artworkCollectionView, view]
    }

    // In order to get the right margins we use custom
    // y indexes, after that we can use x thousands
    // because it gives a hint of the last few sentences
    // and then continues.
    let offsets = [0, 1160]
    let fauxPaginationOffset:CGFloat = 1000

    func scrollPositionForCurrentView() -> CGPoint {
        let withinBounds = index <= offsets.count - 1
        let yOffset = withinBounds ? offsets[index] : index * Int(fauxPaginationOffset)
        return CGPoint(x: 0, y: yOffset)
    }

    @IBAction func gesturedUp(gesture:UISwipeGestureRecognizer) {
        index = max(index-1, 0)
    }

    @IBAction func gesturedDown(gesture:UISwipeGestureRecognizer) {
        let extraContentHeight = scrollView.contentSize.height - 3080
        var extraPages = 0

        // Do we need to show About / Press?
        if extraContentHeight > 0 {
            // Generate the number of pages needed by looking at the delta of 
            // the known amount of space from content and jumping
            extraPages = Int( extraContentHeight.roundUp(fauxPaginationOffset) / CGFloat(fauxPaginationOffset) ) + 1
        }

        index = min(index+1, offsets.count - 1 + extraPages)
    }

    var keyView: UIView {
        if index >= views().count {
            return view
        } else {
            return views()[index]
        }
    }
}

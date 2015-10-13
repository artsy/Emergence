import UIKit
import Moya
import RxCocoa

/// Shows a slideshow of Artsy logos
/// until we've got all the networking for the next VC cached

class AuthViewController: UIViewController {

    var featuredShows:[Show] = []
    var completedAuthentication = false

    @IBOutlet weak var slideshowView: SlideshowView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startSlideshow()
    }

    override func viewDidAppear(animated: Bool) {
        guard let appVC = self.appViewController else {
            return print("you need an app VC")
        }

        appVC.auth {
            self.completedAuthentication = true

            let network = appVC.context.network
            network.request(.FeaturedShows).mapSuccessfulHTTPToObjectArray(Show).subscribe(next: { shows in
                self.featuredShows = shows

                }, error: { error in
                    print("ERROROR \(error)")

                }, completed: nil, disposed: nil)
        }
    }

    lazy var isADeveloper:Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()

    var initialDelay: Double {
        return isADeveloper ? 0.1 : 0.6
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let locationsVC = segue.destinationViewController as? ShowsOverviewViewController {
            locationsVC.cachedShows = self.featuredShows
        }
    }

    // TODO: If authenticated, support skipping on tap?
}

extension AuthViewController {

    // TODO: Move to delegate / functions on the slideshow?

    func startSlideshow() {
        slideshowView.imagePaths = ["image.png", "image2.png", "image.png", "image2.png"]
        slideshowView.next()
        performSelector("nextSlide", withObject: nil, afterDelay: initialDelay)
    }

    func endSlideshow() {
        self.performSegueWithIdentifier("menu", sender: self)
    }

    func shouldFinishSlideshow() -> Bool {
        let isFirstRun = true
        let completedCache = featuredShows.isNotEmpty
        let skipBecauseCached = completedCache && isFirstRun == false
        let outOfSlides = slideshowView.hasMoreSlides() == false
        return outOfSlides || skipBecauseCached
    }

    func nextSlide() {
        if shouldFinishSlideshow() {
            return endSlideshow()
        }

        slideshowView.next()

        let initialDelay = isADeveloper ? 0.1 : 0.6
        var delay = initialDelay + (-0.1 * Double(slideshowView.slidesLeft()) );
        delay = max(delay, 0.1)
        performSelector("nextSlide", withObject: nil, afterDelay: delay)
    }

}

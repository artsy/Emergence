import UIKit
import Moya
import RxCocoa

/// Shows a slideshow of Artsy logos
/// until we've got all the networking for the next VC cached

class AuthViewController: UIViewController {

    var featuredShows:[Show]!
    var completedAuthentication = false
    @IBOutlet weak var slideshowView: SlideshowView!


    override func viewDidAppear(animated: Bool) {

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
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
        if let locationsVC = segue.destinationViewController as? MainMenuViewController {
            locationsVC.featuredShows = self.featuredShows
        }
    }
}

extension AuthViewController {

    // TODO: Move to delegate / functions on the slideshow?

    func startSlideshow() {
        performSelector("nextSlide", withObject: nil, afterDelay: initialDelay)
    }

    func endSlideshow() {
        self.performSegueWithIdentifier("menu", sender: self)
    }

    func nextSlide() {
        if slideshowView.hasMoreSlides() || completedAuthentication {
            return endSlideshow()
        }

        slideshowView.next()

        let initialDelay = isADeveloper ? 0.1 : 0.6
        var delay = initialDelay + (-0.1 * Double(slideshowView.slidesLeft()) );
        delay = max(delay, 0.1)
        performSelector("nextSlide", withObject: nil, afterDelay: delay)
    }

}

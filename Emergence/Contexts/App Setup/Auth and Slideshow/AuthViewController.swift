import UIKit
import Moya
import RxCocoa
import Artsy_Authentication
import ARAnalytics

/// Shows a slideshow of Artsy logos
/// until we've got all the networking for the next VC cached

class AuthViewController: UIViewController {

    var featuredShows:[Show] = []
    var completedAuthentication = false

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var slideshowView: SlideshowView!
    @IBOutlet weak var artsyLogoImageView: UIImageView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        errorMessageLabel.hidden = true
        
        startSlideshow()
        if isFirstRun == false {
            artsyLogoImageView.image = UIImage(named: "artsy-logo-black")
            errorMessageLabel.textColor = .blackColor()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        login()
    }

    func login() {
        guard let appVC = self.appViewController else {
            return print("you need an app VC")
        }

        appVC.auth { success in
            // If you're offline, let people know there is a problem and try
            // again in 0.3 seconds, you've only got 1-2 seconds in here
            // so sooner is better.

            if success == false {
                self.errorMessageLabel.hidden = false
                self.errorMessageLabel.backgroundColor = .clearColor()
                return delay(0.3) { self.login() }
            }

            self.completedAuthentication = true

            let network = appVC.context.network
            network.request(.FeaturedShows).mapSuccessfulHTTPToObjectArray(Show).subscribe(next: { shows in
                    self.featuredShows = shows

                }, error: { error in
                    print("ERROROR \(error)")

                }, completed: nil, disposed: nil)
        }
    }

    lazy var isFirstRun:Bool = {
        let key = "have_ran"
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey(key) { return false }

        ARAnalytics.event("first user install")
        defaults.setBool(true, forKey: key)
        defaults.synchronize()
        return true
    }()


    var initialDelay: Double {
        return 0.7
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

        let images:[String]
        if isFirstRun {
            images = ["slide-bg-1.jpg", "slide-bg-2.jpg", "slide-bg-3.jpg"]
        } else {
            images = ["white.png", "white.png", "white.png"]
        }

        slideshowView.imagePaths = images
        slideshowView.next()
        print("waiting \(initialDelay)")
        performSelector("nextSlide", withObject: nil, afterDelay: initialDelay)
    }

    func endSlideshow() {
        self.performSegueWithIdentifier("menu", sender: self)
    }

    func shouldFinishSlideshow() -> Bool {
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

        var delay = initialDelay - 0.3 + (0.1 * Double(slideshowView.slidesLeft()) );
        delay = max(delay, 0.1)
                print("waiting \(delay)")
        performSelector("nextSlide", withObject: nil, afterDelay: delay)
    }

}

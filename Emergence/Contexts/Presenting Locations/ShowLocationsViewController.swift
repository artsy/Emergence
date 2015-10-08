import UIKit

class ShowLocationsViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var location: Location!
    var shows = [Show]()

    override func awakeFromNib() {
        delegate = self;
        dataSource = self;
        automaticallyAdjustsScrollViewInsets = false;
    }

    override func viewDidLoad() {
        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

        let network = appVC.context.network
        let coords = location.coordinates()
        let showInfo = ArtsyAPI.RunningShowsNearLocation(amount: 2, lat: coords.lat, long: coords.long)
        network.request(showInfo).mapSuccessfulHTTPToObjectArray(Show).subscribe(next: { shows in

                self.shows = shows
                if self.shows.isEmpty {
                    // Show a no shows found?
                } else {
                    let vcs = [self.viewControllerForIndex(0)!]
                    self.setViewControllers(vcs, direction: .Forward, animated: false, completion: nil)
                }

        }, error: { error in
            print("ERROROR \(error)")
        }, completed: nil, disposed: nil)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if shows.count == 1 { return nil }

        let controller = viewController as! ShowViewController
        let newIndex = (controller.index + 1) % shows.count
        return viewControllerForIndex(newIndex)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard shows.count > 1 else { return nil }

        let controller = viewController as! ShowViewController
        let newIndex = (controller.index - 1 < 0) ? controller.index - 1 : shows.count - 1
        return viewControllerForIndex(newIndex)
    }

    func viewControllerForIndex(index: Int) -> ShowViewController? {
        guard -1...shows.count ~= index else { return nil }
        guard let sb = self.storyboard else { return nil }

        guard let controller = sb.instantiateViewControllerWithIdentifier("show") as? ShowViewController else  {
            return nil;
        }

        controller.index = index
        controller.show = shows[index]
        return controller
    }
}

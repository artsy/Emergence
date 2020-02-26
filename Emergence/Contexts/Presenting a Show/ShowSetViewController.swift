import UIKit

class ShowSetViewController: UIPageViewController, UIPageViewControllerDataSource {
    var shows:[Show]!
    var initialIndex: Int!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self

        guard let showVC = viewControllerForIndex(initialIndex) else {
            return print("Wrong current index given to artwork set VC")
        }
        setViewControllers([showVC], direction: .Forward, animated: false, completion: nil)
    }

    func isValidIndex(index: Int) -> Bool {
        return index > -1 && index <= shows.count - 1
    }

    func viewControllerForIndex(index: Int) -> ShowViewController? {
        guard let storyboard = storyboard else { return nil }
        guard isValidIndex(index) else { return nil }

        guard let showVC = storyboard.instantiateViewControllerWithIdentifier("show") as? ShowViewController else { return nil}
        showVC.show = shows[index]
        showVC.index = index

        return showVC
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let currentShowVC = viewController as? ShowViewController else { return nil }
        let newIndex = (currentShowVC.index + 1) % self.shows.count;
        return viewControllerForIndex(newIndex)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let currentShowVC = viewController as? ShowViewController else { return nil }

        var newIndex = currentShowVC.index - 1
        if (newIndex < 0) { newIndex = shows.count - 1 }
        return viewControllerForIndex(newIndex)
    }
    
}

import UIKit

class ArtworkSetViewController: UIPageViewController, UIPageViewControllerDataSource {
    var artworks:[Artwork]!
    var initialIndex: Int!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self

        guard let artworkVC = viewControllerForIndex(initialIndex) else {
            return print("Wrong current index given to artwork set VC")
        }
        setViewControllers([artworkVC], direction: .Forward, animated: false, completion: nil)
    }

    func isValidIndex(index: Int) -> Bool {
        return index > -1 && index <= artworks.count - 1
    }

    func viewControllerForIndex(index: Int) -> ArtworkViewController? {
        guard let storyboard = storyboard else { return nil }
        guard isValidIndex(index) else { return nil }

        guard let artworkVC = storyboard.instantiateViewControllerWithIdentifier("artwork") as? ArtworkViewController else { return nil}
        artworkVC.artwork = artworks[index]
        artworkVC.index = index
        return artworkVC
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let currentArtworkVC = viewController as? ArtworkViewController else { return nil }
        let newIndex = (currentArtworkVC.index + 1) % self.artworks.count;
        return viewControllerForIndex(newIndex)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let currentArtworkVC = viewController as? ArtworkViewController else { return nil }

        var newIndex = currentArtworkVC.index - 1
        if (newIndex < 0) { newIndex = artworks.count - 1 }
        return viewControllerForIndex(newIndex)
    }

}

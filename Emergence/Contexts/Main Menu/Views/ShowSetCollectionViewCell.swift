import UIKit
import SDWebImage

class ShowSetCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet weak var featuredShowsLabel: UILabel!
    static let reuseIdentifier = "ShowSetCollectionViewCell"

    private var emitter:ShowEmitter?
    func configureWithEmitter(emitter:ShowEmitter) {
        self.emitter = nil
        collectionView.reloadData()

        self.emitter = emitter
        self.updateTitle(emitter)

        emitter.onUpdate { shows in
            self.updateTitle(emitter)

            // Alright, this took me ages to figure out
            // https://artsy.slack.com/archives/mobile/p1445518064000821

            // Note: reloadData is the safe path, and never crashes.

            let cv = self.collectionView

            // Make sure there's no funny business around our expectations
            // that we can _add_ shows

            let previousShowCount = cv.numberOfItemsInSection(0)
            if previousShowCount > shows.count || previousShowCount == 0 {
                cv.reloadData()
                return
            }

            // Problems occur when scrolling and appending, so, don't allow it
            // yes, there's a potential for flashes of the image as you're scrolling
            // but I'll take shipped over perfect.

            if self.hostViewController.scrolling {
                cv.reloadData()
                return
            }

            // OK, get the difference between the shows and how many we want to show
            // and insert them in a batch update.

            cv.batch() {
                let paths = (previousShowCount ..< shows.count).map { NSIndexPath(forRow: $0, inSection: 0) }
                if paths.isNotEmpty { self.collectionView.insertItemsAtIndexPaths(paths) }
            }
        }
    }

    override func prepareForReuse() {
        self.emitter =  nil 
        self.collectionView.reloadData()
    }

    func updateTitle(emitter: ShowEmitter) {
        titleLabel.text = emitter.title

        if let locationEmitter = emitter as? LocationBasedShowEmitter where locationEmitter.numberOfShows > 0 && locationEmitter.done {
            featuredShowsLabel.text = "\(emitter.numberOfShows) Current Shows"
        } else {
            featuredShowsLabel.text = ""
        }
    }

    // Pass the focus through to the sub-collection view

    override var preferredFocusedView: UIView? {
        return collectionView
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let emitter = emitter else { return 0 }
        return emitter.numberOfShows
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(ShowCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
    }

    // MARK: UICollectionViewDelegate

    // This feels icky, but I'm unable to think of a better way ATM, also used
    // in the ShowSetCollectionViewCell to check if we're scrolling

    @IBOutlet var hostViewController: ShowsOverviewViewController!

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let emitter = emitter else { return }
        let show = emitter.showAtIndexPath(indexPath)
        hostViewController.showTapped(show)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ShowCollectionViewCell else { fatalError("Expected to display a ShowCollectionViewCell") }
        guard let emitter = emitter else { return }

        let show = emitter.showAtIndexPath(indexPath)
        cell.configureWithShow(show)
    }


}

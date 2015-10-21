import UIKit
import SDWebImage

class ShowSetCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!

    static let reuseIdentifier = "ShowSetCollectionViewCell"

    private var emitter:ShowEmitter!
    func configureWithEmitter(emitter:ShowEmitter) {
        self.emitter = nil
        collectionView.reloadData()

        self.emitter = emitter
        titleLabel.attributedText = attributedTitle(emitter)

        emitter.onUpdate { shows in
            self.titleLabel.attributedText = self.attributedTitle(emitter)

            let previousShowCount = self.collectionView.numberOfItemsInSection(0)
            self.collectionView.performBatchUpdates({
                // create an array of nsindexpaths for the new items being added
                let paths = (previousShowCount ..< shows.count).map({ NSIndexPath(forRow: $0, inSection: 0) })
                self.collectionView.insertItemsAtIndexPaths(paths)
            }, completion: nil)

        }
    }

    func attributedTitle(emitter: ShowEmitter) -> NSAttributedString {
        let title = NSMutableAttributedString(string: emitter.title, attributes: [
            NSFontAttributeName: UIFont.serifFontWithSize(50)
        ])

        if let locationEmitter = emitter as? LocationBasedShowEmitter where locationEmitter.numberOfShows > 0 && locationEmitter.done {
            let showString = NSAttributedString(string: "   \(emitter.numberOfShows) Current Shows", attributes: [NSFontAttributeName: UIFont.serifItalicFontWithSize(30)])
            title.appendAttributedString(showString)
        }

        return title
    }

    // Pass the focus through to the sub-collection view
    override var preferredFocusedView: UIView? {
        return collectionView
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emitter.numberOfShows
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(ShowCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
    }

    // MARK: UICollectionViewDelegate

    // This feels icky, but I'm unable to think of a better way ATM
    @IBOutlet var hostViewController: ShowsOverviewViewController!
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let show = emitter.showAtIndexPath(indexPath)
        hostViewController.showTapped(show)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? ShowCollectionViewCell else { fatalError("Expected to display a ShowCollectionViewCell") }

        let show = emitter.showAtIndexPath(indexPath)
        cell.configureWithShow(show)
    }


}

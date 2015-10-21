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

            // If we're not highlighted, dont bother with the fancy appending
            if let focusedCell = UIScreen.mainScreen().focusedView as? UICollectionViewCell where focusedCell.isDescendantOfView(self.collectionView) {
                return self.collectionView.reloadData()
            }

            // Sigh, I wrote this in 2011,
            // https://github.com/artsy/eigen/blob/259be8ce00b07a33e02d4444ee01e5589df9b2f1/Artsy/View_Controllers/Embedded/Generics/AREmbeddedModelsViewController.m#L163

            // I feel like I just don't _get_ something, somewhere, and thus can never learn how the hell to do this
            // without crashing.

//            print("append")
//            let previousShowCount = self.collectionView.numberOfItemsInSection(0)
//            self.collectionView.performBatchUpdates({
//
//                // create an array of nsindexpaths for the new items being added
//                let paths = (previousShowCount ..< shows.count).map { NSIndexPath(forRow: $0, inSection: 0) }
//
//                print("from \(previousShowCount) - \(shows.count)")
//                print("emitter says \(emitter.numberOfShows)")
//                print("paths -> \(paths.map { $0.row })")
//                if paths.isNotEmpty { self.collectionView.insertItemsAtIndexPaths(paths) }
//
//            }, completion: { _ in })

            self.collectionView.reloadData()
        }
    }

    override func prepareForReuse() {
        self.emitter = nil
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

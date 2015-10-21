import UIKit
import SDWebImage
import SSDataSources

class ShowSetCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!

    static let reuseIdentifier = "ShowSetCollectionViewCell"

    private var emitter:ShowEmitter!
    private var dataSource: SSArrayDataSource?

    func configureWithEmitter(configureEmitter:ShowEmitter) {
        if dataSource == nil {
            guard let theDataSource = SSArrayDataSource(items:[]) else { return }
            theDataSource.clearItems()
            theDataSource.collectionView = collectionView

            theDataSource.cellCreationBlock = { obj, parent, index in
                return parent.dequeueReusableCellWithReuseIdentifier(ShowCollectionViewCell.reuseIdentifier, forIndexPath: index)
            }

            theDataSource.cellConfigureBlock = { cell, show, parent, index in
                guard let cell = cell as? ShowCollectionViewCell else { fatalError("Expected to display a ShowCollectionViewCell") }
                guard let show = show as? Show else { fatalError("Expected to display a Show") }
                
                cell.configureWithShow(show)
            }
            dataSource = theDataSource
        }

        emitter = configureEmitter
        titleLabel.attributedText = attributedTitle(configureEmitter)
        dataSource?.updateItems(emitter.shows as [AnyObject])

        emitter.onUpdate { emitter, shows, before, delta in
            self.dataSource?.appendItems(delta)
        }
    }

    override func prepareForReuse() {
        dataSource?.clearItems()
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

    // MARK: UICollectionViewDelegate

    // This feels icky, but I'm unable to think of a better way ATM
    @IBOutlet var hostViewController: ShowsOverviewViewController!
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let show = emitter.showAtIndexPath(indexPath)
        hostViewController.showTapped(show)
    }
}

import UIKit
import SDWebImage

/// Just a dumb presentation class
class ShowCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var partnerNameLabel: UILabel!
    @IBOutlet weak var showNameLabel: UILabel!
    @IBOutlet weak var ausstellungsdauerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}


/// Handles going from a [Show] to -> UICollectionView cells

class FeaturedShowsPresentor: NSObject, UICollectionViewDataSource {
    let shows: [Show]
    let collectionView: UICollectionView

    init(shows: [Show], collectionView: UICollectionView) {
        self.shows = shows
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let show = shows[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("show", forIndexPath: indexPath) as! ShowCollectionViewCell


        cell.showNameLabel.text = show.name
        cell.partnerNameLabel.text = show.showDescription

        if let thumbnailURL = show.bestAvailableThumbnailURL() {
            cell.imageView.sd_setImageWithURL(thumbnailURL)
        } else {
            print("Could not find a thumbnail for \(show.name) - found \(show.imageVersions)")
        }

        if let start = show.startDate, end = show.endDate {
            cell.ausstellungsdauerLabel.text = start.ausstellungsdauerToDate(end)
        } else {
            cell.ausstellungsdauerLabel.text = ""
        }

        return cell
    }
}
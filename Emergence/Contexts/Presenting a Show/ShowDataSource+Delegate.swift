import UIKit
import CoreGraphics
import ARCollectionViewMasonryLayout
import SDWebImage
import RxSwift
import Artsy_UIColors
import SDWebImage

// Just a dumb protocol to pass a message back that
// something has been tapped on

protocol ShowItemTapped {
    func didTapArtwork(item: Artwork)
}

// Generic DataSource for dealing with an image based collectionview

class CollectionViewDelegate <T>: NSObject, ARCollectionViewMasonryLayoutDelegate {

    let dimensionLength:CGFloat
    let itemDataSource: CollectionViewDataSource<T>
    let delegate: ShowItemTapped?
    let show: Show

    // The extra height associated with _none_ image space in the cell, such as artwork metadata
    var internalPadding:CGFloat = 0

    init(datasource: CollectionViewDataSource<T>, collectionView: UICollectionView, show: Show, delegate: ShowItemTapped?) {
        itemDataSource = datasource
        dimensionLength = collectionView.bounds.height
        self.delegate = delegate
        self.show = show

        super.init()

        let layout = ARCollectionViewMasonryLayout(direction: .Horizontal)
        layout.rank = 1
        layout.dimensionLength = dimensionLength
        layout.itemMargins = CGSize(width: 40, height: 0)
        layout.contentInset = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 90)

        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.setNeedsLayout()
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let item = itemDataSource.itemForIndexPath(indexPath)

        guard let actualItem = item, image: Image = imageForItem(actualItem) else {
            // otherwise, ship a square
            return dimensionLength
        }

        return widthForImage(image, capped: collectionView.bounds.width)
    }

    func widthForImage(image: Image, capped: CGFloat) -> CGFloat {
        let width: CGFloat
        let ratio = image.aspectRatio ?? image.imageSize.width / image.imageSize.height
        width = (dimensionLength - internalPadding) * ratio

        return min(width, capped)
    }

    func imageForItem(item:T) -> Image? {
        // If it's an artwork grab the default image
        if var artwork = item as? Artwork, let defaultImage = artwork.defaultImage, let actualImage = defaultImage as? Image {
            return actualImage

        } else if let actualImage = item as? Image {
            // otherwise it is an image
            return actualImage
        }

        return nil
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        guard let item = itemDataSource.itemForIndexPath(indexPath) else { return }
        guard let image = imageForItem(item) else { return }

        if let cell = cell as? ImageCollectionViewCell {
            if image.imageFormatString == show.imageFormatString {
                // We can use the install shot from the ShowsOverview cache!

                let oldThumbnail = image.bestAvailableThumbnailURL()
                guard let newThumbnail = image.geminiThumbnailURLWithHeight(Int(dimensionLength)) else { return print("Could not generate a thumbnail for image") }
                cell.image.ar_setImageURL(newThumbnail, takeThisURLFromCacheFirst: oldThumbnail, size:image.imageSize)

            } else {
                cell.image.ar_setImage(image, height: dimensionLength)

            }
        }

        if let cell = cell as? ArtworkCollectionViewCell, let artwork = item as? Artwork {
            cell.artistNameLabel.text = artwork.oneLinerArtist()
            cell.titleLabel.attributedText = artwork.titleWithDate()
            cell.image.ar_setImage(image, height: dimensionLength)
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let item = itemDataSource.itemForIndexPath(indexPath) else { return }

        if let artwork = item as? Artwork {
            delegate?.didTapArtwork(artwork)
        }
    }
}

class CollectionViewDataSource <T>: NSObject, UICollectionViewDataSource {
    let collectionView: UICollectionView
    let cellIdentifier: String
    let cache: SDWebImagePrefetcher
    let show: Show

    var items: [T]?

    init(_ collectionView: UICollectionView, cellIdentifier: String, show: Show, cache: SDWebImagePrefetcher) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        self.cache = cache
        self.show = show
        super.init()

        collectionView.dataSource = self
    }

    func subscribeToRequest(request: Observable<[(T)]>?) {
        guard let request = request else { return }

        request.subscribe() { networkItems in
            guard let elements = networkItems.element else { return }
            let newItems = elements.sort(self.moveCachableImageToTop)

            if let items = self.items {
                self.items = items + newItems
            } else {
                self.items = newItems
            }

            self.collectionView.batch() {
                let previousItemsCount = self.collectionView.numberOfItemsInSection(0)
                let paths = (previousItemsCount ..< self.items!.count).map({ NSIndexPath(forRow: $0, inSection: 0) })
                self.collectionView.insertItemsAtIndexPaths(paths)
            }

            self.precache(self.items)
        }
    }

    func itemForIndexPath(path: NSIndexPath) -> T? {
        return items?[path.row]
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
    }

    // Sort

    func moveCachableImageToTop(lhs:T, rhs:T) -> Bool {
        if imageForItem(lhs)?.imageFormatString == show.imageFormatString { return true }
        return false
    }

    // Low priority image caching
    func precache(items:[T]?) {
        guard let items = items else { return }
        let images = items.map(imageForItem).flatMap { $0 }
        var urls = images.map { $0.bestThumbnailWithHeight(collectionView.bounds.height) }.flatMap { $0 }


        // I _feel_ like the precaching is getting in the way of showing the first install shot
        if let _ = items.first as? Image {
            urls.removeAtIndex(0)
        }

        cache.prefetchURLs(urls)
    }

    // As these two are separate generic classes, they can't really share this function, thus: duped.

    func imageForItem(item:T) -> Image? {
        // If it's an artwork grab the default image
        if var artwork = item as? Artwork, let defaultImage = artwork.defaultImage, let actualImage = defaultImage as? Image {
            return actualImage

        } else if let actualImage = item as? Image {
            // otherwise it is an image
            return actualImage
        }

        return nil
    }


}

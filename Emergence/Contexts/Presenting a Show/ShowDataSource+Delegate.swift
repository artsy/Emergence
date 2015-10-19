import UIKit
import CoreGraphics
import ARCollectionViewMasonryLayout
import SDWebImage
import RxSwift
import Artsy_UIColors

// Just a dump protocol to pass a message back that 
// something has been tapped on

protocol ShowItemTapped {
    func didTapArtwork(item: Artwork)
}

// Generic DataSource for dealing with an image based collectionview

class CollectionViewDelegate <T>: NSObject, ARCollectionViewMasonryLayoutDelegate {

    let dimensionLength:CGFloat
    let artworkDataSource: CollectionViewDataSource<T>
    let delegate: ShowItemTapped?

    init(datasource: CollectionViewDataSource<T>, collectionView: UICollectionView, delegate: ShowItemTapped?) {
        artworkDataSource = datasource
        dimensionLength = collectionView.bounds.height
        self.delegate = delegate

        super.init()

        let layout = ARCollectionViewMasonryLayout(direction: .Horizontal)
        layout.rank = 1
        layout.dimensionLength = dimensionLength
        layout.itemMargins = CGSize(width: 40, height: 0)

        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.setNeedsLayout()
    }

    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: ARCollectionViewMasonryLayout!, variableDimensionForItemAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let item = artworkDataSource.itemForIndexPath(indexPath)

        guard let actualItem = item, image: Image = imageForItem(actualItem) else {
            // otherwise, ship a square
            return dimensionLength
        }

        return widthForImage(image, capped: collectionView.bounds.width)
    }

    func widthForImage(image: Image, capped: CGFloat) -> CGFloat {
        let width: CGFloat
        if let ratio = image.aspectRatio {
            width = dimensionLength / ratio

        } else {
            let ratio = image.imageSize.width / image.imageSize.height
            width = dimensionLength / ratio
        }

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

        guard let item = artworkDataSource.itemForIndexPath(indexPath) else { return }
        guard let image = imageForItem(item) else { return }

        if let cell = cell as? ImageCollectionViewCell, let url = image.bestThumbnailWithHeight(dimensionLength) {
            cell.image.sd_setImageWithURL(url)
            cell.image.backgroundColor = UIColor.artsyLightGrey()
        }

        if let cell = cell as? ArtworkCollectionViewCell, let artwork = item as? Artwork, let url = image.bestThumbnailWithHeight(dimensionLength) {
            cell.artistNameLabel.text = artwork.oneLinerArtist()
            cell.titleLabel.text = artwork.title
            cell.image.sd_setImageWithURL(url)
            cell.image.backgroundColor = UIColor.artsyLightGrey()
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let item = artworkDataSource.itemForIndexPath(indexPath) else { return }

        if let artwork = item as? Artwork {
            delegate?.didTapArtwork(artwork)
        }
    }
}

class CollectionViewDataSource <T>: NSObject, UICollectionViewDataSource {
    let collectionView: UICollectionView
    let cellIdentifier: String
    var items: [T]?

    init(_ collectionView: UICollectionView, request: Observable<[(T)]>, cellIdentifier: String) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        super.init()

        collectionView.dataSource = self
        request.subscribe() { items in
            self.items = items.element
            self.collectionView.reloadData()
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
    
}

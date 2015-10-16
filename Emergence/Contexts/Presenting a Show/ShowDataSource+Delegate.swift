import UIKit
import ARCollectionViewMasonryLayout
import SDWebImage
import RxSwift

// Generic DataSource for dealing with an image based collectionview

class CollectionViewDelegate <T>: NSObject, ARCollectionViewMasonryLayoutDelegate {

    let dimensionLength:CGFloat
    let artworkDataSource: CollectionViewDataSource<T>

    init(datasource: CollectionViewDataSource<T>, collectionView: UICollectionView) {
        artworkDataSource = datasource
        dimensionLength = collectionView.bounds.height

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

        guard let actualItem = item, image:Image = imageForItem(actualItem) else {
            // otherwise, ship a square
            return dimensionLength
        }

        if let ratio = image.aspectRatio {
            return dimensionLength * ratio
        }

        // Hrm is this right?
        let ratio = image.imageSize.height / image.imageSize.width
        return dimensionLength * ratio
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
        }

        if let cell = cell as? ArtworkCollectionViewCell, let artwork = item as? Artwork, let url = image.bestThumbnailWithHeight(dimensionLength) {
            cell.artistNameLabel.text = artwork.oneLinerArtist()
            cell.titleLabel.text = artwork.title
            cell.image.sd_setImageWithURL(url)
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
        request.subscribe(next: { items in
            self.items = items
            self.collectionView.reloadData()

            }, error: { error in
                print("ERROROR \(error)")

            }, completed: nil, disposed: nil)
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

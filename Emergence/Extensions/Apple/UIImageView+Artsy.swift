import UIKit
import Artsy_UIColors
import SDWebImage

extension UIImageView {

    func ar_setImageURL(url: NSURL, takeThisURLFromCacheFirst: NSURL?, size: CGSize) {
        let manager = SDWebImageManager.sharedManager()
        if let cacheuRL = takeThisURLFromCacheFirst where manager.cachedImageExistsForURL(takeThisURLFromCacheFirst) {
            let key = manager.cacheKeyForURL(cacheuRL)
            let smallerInitialThumbnail = manager.imageCache.imageFromMemoryCacheForKey(key)
            sd_setImageWithURL(url, placeholderImage:smallerInitialThumbnail)
        } else {
            ar_setImageWithURL(url, size: size)
        }

    }

    func ar_setImage(image: Image, height:CGFloat) {
        guard let thumbnail = image.bestThumbnailWithHeight(height) else { return }
        ar_setImageWithURL(thumbnail, color: .artsyGrayLight(), size: image.imageSize)
    }

    func ar_setImageWithURL(url:NSURL, color: UIColor = .artsyGrayLight(), size:CGSize = CGSize(width: 600, height: 400)) {
        async {
            let image = UIImage.imageFromColor(color, size: size)
            self.sd_setImageWithURL(url, placeholderImage: image)
        }
    }

}
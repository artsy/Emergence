import UIKit
import Artsy_UIColors
import SDWebImage

extension UIImageView {

    func ar_setImage(image: Image, height:CGFloat) {
        guard let thumbnail = image.bestThumbnailWithHeight(height) else { return }
        ar_setImageWithURL(thumbnail, color: .artsyLightGrey(), size: image.imageSize)
    }

    func ar_setImageWithURL(url:NSURL, color: UIColor = .artsyLightGrey(), size:CGSize = CGSize(width: 600, height: 400)) {
        async {
            let image = UIImage.imageFromColor(color, size: size)
            self.sd_setImageWithURL(url, placeholderImage: image)
        }
    }

}
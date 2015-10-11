import UIKit

class SlideshowView: UIView {
    var imagePaths: [String] = []
    var index = 0

    var imageView: UIImageView {
        let imageView = UIImageView(frame: self.bounds)
        addSubview(imageView)
        imageView.contentMode = .ScaleAspectFill;
        imageView.image = self.imageAtIndex(0)
        return imageView
    }

    func imageAtIndex(index: Int) -> UIImage {
        return UIImage(named: imagePaths[index])!
    }

    func next() {
        index++
        if index == imagePaths.count { index = 0 }
        imageAtIndex(index)
    }

    func slidesLeft() -> Int {
        return imagePaths.count - index
    }


    func hasMoreSlides() -> Bool {
        return index < imagePaths.count - 1
    }
}

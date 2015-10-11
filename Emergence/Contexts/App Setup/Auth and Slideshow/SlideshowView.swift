import UIKit

/// Takes a [String] as imagePaths and goes through them all

class SlideshowView: UIView {
    var imagePaths: [String] = []
    private var index = -1

    private var imageView: UIImageView {
        let imageView = UIImageView(frame: self.bounds)
        addSubview(imageView)
        imageView.contentMode = .ScaleAspectFill;
        imageView.image = self.imageAtIndex(0)
        return imageView
    }

    private func imageAtIndex(index: Int) -> UIImage {
        let imageURL = NSBundle.mainBundle().URLForResource(imagePaths[index], withExtension: nil)!
        let imageData = NSData(contentsOfURL: imageURL)!
        return UIImage(data: imageData)!
    }

    func next() {
        index++
        if index == imagePaths.count { index = 0 }
        imageView.image = imageAtIndex(index)
    }

    func slidesLeft() -> Int {
        return imagePaths.count - index
    }

    func hasMoreSlides() -> Bool {
        return index < imagePaths.count - 1
    }
}

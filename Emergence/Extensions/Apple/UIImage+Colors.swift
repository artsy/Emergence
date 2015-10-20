import UIKit
import CoreGraphics

extension UIImage {

    /// Returns an image with the same size as the size
    static func imageFromColor(color: UIColor, size:CGSize) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: size)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);

        let image =  UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }

}
// TODO: convert back to objc then migrate into Artsy+UILabels

import UIKit
import Artsy_UIFonts

extension NSAttributedString {
    static func artworkTitleAndDateString(title:String?, dateString:String?, fontSize:CGFloat = 16) -> NSAttributedString {

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3

        let title = title ?? "Untitled"
        let string = NSMutableAttributedString(string: title, attributes: [
                NSParagraphStyleAttributeName:paragraphStyle,
                NSFontAttributeName: UIFont.serifFontWithSize(fontSize)
        ])

        if let dateString = dateString {
            let dateString = NSAttributedString(string: ", " + dateString, attributes: [NSFontAttributeName: UIFont.serifItalicFontWithSize(fontSize)])
            string.appendAttributedString(dateString)
        }

        return string
    }
}
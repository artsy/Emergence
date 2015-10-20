import UIKit
import Artsy_UIFonts

class SanSerifButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel!.font = UIFont.sansSerifFontWithSize(24)
        
    }
}

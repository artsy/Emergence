import Artsy_UILabels
import Artsy_UIFonts

// In our other apps serif text is mostly shown 
// over a white BG, so we force a white BG and declare
// it opaque for a rendering speed boost

// in here it's mostly serif text above an image
// where we dont want those defaults

class TransparentSerifLabels: ARSerifLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clearColor()
        opaque = false
    }
}

class TransparentItalicSerifLabels: ARSerifLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.serifItalicFontWithSize(font.pointSize)
        backgroundColor = .clearColor()
        opaque = false
    }
}

class TransparentBoldSerifLabels: ARSerifLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.serifBoldFontWithSize(font.pointSize)
        backgroundColor = .clearColor()
        opaque = false
    }
}

class TransparentSanSerifLabel: ARSansSerifLabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.sansSerifFontWithSize(font.pointSize)
        backgroundColor = .clearColor()
        opaque = false
    }

}
import Artsy_UILabels

/// Pretty weird case where the labels for "About this Show" and
/// the press release, were always double the hight that they needed
/// Couldn't figure out the reason...

class HalfIntrinsicHeightSerifLabel: ARSerifLabel {
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        return CGSize(width: size.width, height: size.height/2.5)
    }
}

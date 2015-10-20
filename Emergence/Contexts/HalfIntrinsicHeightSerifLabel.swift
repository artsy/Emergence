import Artsy_UILabels

/// Pretty weird case where the labels for "About this Show" and
/// the press release, were always double the height that they needed
/// Couldn't figure out the reason...

/// I tried every version of the Garamond font we have
/// and still got bad behavior.

class HalfIntrinsicHeightSerifLabel: ARSerifLabel {
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        let height = max(size.height/2.73, 30)
        return CGSize(width: size.width, height: height)
    }
}

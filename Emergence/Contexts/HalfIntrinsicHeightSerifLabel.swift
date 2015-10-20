import Artsy_UILabels

/// Pretty weird case where the labels for "About this Show" and
/// the press release, were always double the height that they needed
/// Couldn't figure out the reason...

/// I tried every version of the Garamond font we have
/// and still got bad behavior.


class HalfIntrinsicHeightSerifLabel: ARSerifLabel {
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        let guestiHeight = size.height/2.73
        let height = guestiHeight.roundUp(30)
        return CGSize(width: size.width, height: height)
    }
}


extension CGFloat {
    /// Rounds up current value to the nearest x
    func roundUp(divisor: CGFloat) -> CGFloat {
        let rem = self % divisor
        return rem == 0 ? self : self + divisor - rem
    }
}

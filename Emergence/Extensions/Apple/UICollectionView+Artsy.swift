import UIKit

extension UICollectionView {
    /// This API annoyed me
    func batch(closure: ()->()) {
        performBatchUpdates(closure, completion: nil)
    }
}
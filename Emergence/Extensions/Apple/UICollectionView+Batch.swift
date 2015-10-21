import UIKit

extension UICollectionView {

    /// This was annoting me.
    func batch(updates: () -> ()) {
        performBatchUpdates(updates, completion: nil)
    }

}


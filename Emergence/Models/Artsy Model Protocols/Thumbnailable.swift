/// Indicates that the model can shown as a thumbnail
/// without having to go through a collection of Imageables

import Foundation

enum ThumnailableSizes: String {
    case Large = "large"
    case LargeRect = "large_rectangle"
    case Larger = "larger"
    case Medium = "medium"
    case MediumRect = "medium_rectangle"
    case Normalized = "normalized"
    case Small = "small"
    case Tall = "tall"
}

protocol Thumbnailable {
    var thumbnailImageFormatString: String { get }
    var thumbnailImageVersions: [String] { get }
}

extension Thumbnailable {

    func bestAvailableThumbnailURL() -> NSURL {
        let url = thumbnailImageFormatString.stringByReplacingOccurrencesOfString("{?image_version}", withString: ThumnailableSizes.Large.rawValue)
        return NSURL(string: url)!
    }

}
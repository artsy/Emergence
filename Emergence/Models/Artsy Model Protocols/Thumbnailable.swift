/// Indicates that the model can shown as a thumbnail
/// without having to go through a collection of Imageables

import Foundation

enum ThumnailableSize: String {
    case Featured = "featured"
    case General = "general"
    case Large = "large"
    case LargeRect = "large_rectangle"
    case Larger = "larger"
    case Medium = "medium"
    case MediumRect = "medium_rectangle"
    case FourThirds = "four_thirds"
    case Normalized = "normalized"
    case Small = "small"
    case Tall = "tall"
}

protocol ImageURLThumbnailable {
    var imageFormatString: String { get }
    var imageVersions: [String] { get }
}

extension ImageURLThumbnailable {

    func bestAvailableThumbnailURL() -> NSURL? {
        let thumbnail = findFirstSizeInVersions([.Featured, .Larger, .Large, .Normalized])
        return thumbnailWithSize(thumbnail)
    }

    func bestAvailableSquareThumbnailURL() -> NSURL? {
        let thumbnail = findFirstSizeInVersions([.LargeRect, .MediumRect, .Normalized])
        return thumbnailWithSize(thumbnail)
    }

    private func findFirstSizeInVersions(sizes: [ThumnailableSize]) -> ThumnailableSize? {
        let rawSizes = sizes.map({ $0.rawValue })

        for thumbnailString in imageVersions {
            if rawSizes.contains(thumbnailString) {
                let index = rawSizes.indexOf(thumbnailString)!
                return sizes[index]
            }
        }
        return nil
    }

    private func thumbnailWithSize(size: ThumnailableSize?) -> NSURL? {
        guard let thumbnail = size else {
            return nil
        }

        var url = imageFormatString.stringByReplacingOccurrencesOfString("{?image_version}", withString: thumbnail.rawValue)
        url = url.stringByReplacingOccurrencesOfString(":version", withString: thumbnail.rawValue)
        return NSURL(string: url)!
    }
}
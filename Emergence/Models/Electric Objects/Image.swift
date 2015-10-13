import Gloss
import Foundation
import CoreGraphics

struct Image: Imageable, ImageURLThumbnailable {
    let id: String
    let imageFormatString: String
    let imageVersions: [String]
    let imageSize: CGSize
    let aspectRatio: CGFloat?

    let isDefault: Bool
}

extension Image: Decodable {
    init?(json: JSON) {

        guard
            let idValue: String = "id" <~~ json,
            let imageFormatStringValue: String = "image_url" <~~ json,
            let imageVersionsValue: [String] = "image_versions" <~~ json
        else {
            return nil
        }

        id = idValue
        imageFormatString = imageFormatStringValue
        imageVersions = imageVersionsValue

        imageSize = CGSize(width: "original_width" <~~ json ?? 1, height: "original_height" <~~ json ?? 1)
        aspectRatio = "aspect_ratio" <~~ json
        isDefault = "is_default" <~~ json ?? false
    }
}
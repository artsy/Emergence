import Foundation
import CoreGraphics

struct Image: Imageable {
    let id: String
    let imageFormatString: String
    let imageVersions: [String]
    let imageSize: CGSize
    let aspectRatio: CGFloat?
    
    let baseURL: NSURL
    let tileSize: Int
    let maxTiledHeight: Int
    let maxTiledWidth: Int
    let maxLevel: Int
    let isDefault: Bool
}

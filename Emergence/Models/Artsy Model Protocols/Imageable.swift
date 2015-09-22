import Foundation
import CoreGraphics

/// Encapsulates shared behavior within Image types

protocol Imageable {
    var id: String { get }

    /// There is a new image url API, use this instead
    var imageFormatString: String { get }
    var imageVersions: [String] { get }
    
    var imageSize: CGSize { get }
    var aspectRatio: CGFloat? { get }
    
    var baseURL: NSURL { get }
    var tileSize: Int { get }
    var maxTiledHeight: Int { get }
    var maxTiledWidth: Int { get }
    var maxLevel: Int { get }
    var isDefault: Bool { get }
}

/// Extends the Imageable protocol with image URL handling
extension Imageable {
    
}
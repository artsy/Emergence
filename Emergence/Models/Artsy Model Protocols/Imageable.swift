import Foundation
import CoreGraphics

/// Encapsulates shared behavior within Image types

protocol Imageable {
    var id: String { get }

    var imageSize: CGSize { get }
    var aspectRatio: CGFloat? { get }
    
    var isDefault: Bool { get }
}

/// Extends the Imageable protocol with image URL handling

extension Imageable {
   
}


protocol ImageTileable {
    var tileBaseURL: NSURL { get }
    var tileSize: Int { get }
    var maxTiledHeight: Int { get }
    var maxTiledWidth: Int { get }
    var maxLevel: Int { get }
}

/// Encapsulates shared behavior within Show types

protocol Showable {
    var installShots: [Imageable] { get }
    var artworks: [Artworkable] { get }
}

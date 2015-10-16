/// Encapsulates shared behavior within Show types

protocol Showable {
    var artworks: [Artworkable] { get }

    var id: String { get }
    var name: String { get }
}

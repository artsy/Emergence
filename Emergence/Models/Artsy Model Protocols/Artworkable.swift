/// Encapsulates shared behavior within Artwork types

protocol Artworkable {
    var id: String { get }
    var title: String { get }
    var medium: String { get }

    var artists: [Artistable]? { get }
    var images: [Imageable] { get }
}

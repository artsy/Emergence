import Gloss

struct Show: Showable {
    let name: String

    let installShots: [Imageable]
    let artworks: [Artworkable]
}

extension Show: Decodable {
    init?(json: JSON) {
        guard let name: String = "name" <~~ json else {
            return nil
        }

        self.name = name
        artworks = []
        installShots = []
    }
}
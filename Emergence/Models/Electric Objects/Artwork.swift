import Gloss
import ISO8601DateFormatter

struct Artwork: Artworkable {
    let id: String
    let title: String
    let medium: String
    
    let artists: [Artistable]?
    let images: [Imageable]
}

extension Artwork: Decodable {
    init?(json: JSON) {

        guard
            let idValue: String = "name" <~~ json,
            let titleValue: String = "name" <~~ json,
            let mediumValue: String = "medium" <~~ json
        else {
            return nil
        }

        id = idValue
        title = titleValue
        medium = mediumValue

        artists = []
        images = []
    }
}


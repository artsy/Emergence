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
            let idValue: String = "id" <~~ json,
            let titleValue: String = "title" <~~ json,
            let mediumValue: String = "medium" <~~ json
        else {
            return nil
        }

        id = idValue
        title = titleValue
        medium = mediumValue

        artists = []
        if let imagesValue: [Image] = "images" <~~ json {
           images = imagesValue.map { return $0 as Imageable }
        } else {
            images = []
        }
    }
}


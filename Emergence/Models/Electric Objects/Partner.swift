import Gloss

struct Partner: Partnerable {
    let id:String
    let name:String
}

extension Partner: Decodable {
    init?(json: JSON) {

        guard
            let idValue: String = "id" <~~ json,
            let nameValue: String = "name" <~~ json
        else {
            return nil
        }

        id = idValue
        name = nameValue
    }
}


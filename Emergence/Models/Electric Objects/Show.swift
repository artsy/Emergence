import Gloss
import ISO8601DateFormatter

struct Show: Showable, Thumbnailable {
    let name: String

    let pressRelease: String?
    let showDescription: String?

    let startDate: NSDate?
    let endDate: NSDate?

    var installShots: [Imageable]
    var artworks: [Artworkable]

    var thumbnailImageFormatString: String
    var thumbnailImageVersions: [String]
}

let dateShowFormatter = ISO8601DateFormatter()


extension Show: Decodable {
    init?(json: JSON) {

        guard let name: String = "name" <~~ json else {
            return nil
        }

        self.name = name

        if let start: String = "start_at" <~~ json {
            self.startDate = dateShowFormatter.dateFromString(start)
        } else {
            self.startDate = nil
        }

        if let end: String = "start_at" <~~ json {
            self.endDate = dateShowFormatter.dateFromString(end)
        } else {
            self.endDate = nil
        }

        self.pressRelease = "press_release" <~~ json
        self.showDescription = "description" <~~ json

        artworks = []
        installShots = []
        thumbnailImageFormatString = ""
        thumbnailImageVersions = [""]
    }
}
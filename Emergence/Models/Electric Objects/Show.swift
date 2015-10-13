import Gloss
import ISO8601DateFormatter

struct Show: Showable, ImageURLThumbnailable {
    let id: String
    let name: String
    let partner: Partnerable

    let pressRelease: String?
    let showDescription: String?

    let startDate: NSDate?
    let endDate: NSDate?

    var installShots: [Imageable]
    var artworks: [Artworkable]

    var imageFormatString: String
    var imageVersions: [String]

    static func stubbedShow() -> Show {
        let partner = Partner(json:["id": "2311", "name":"El Partner"])!
        let image = Image(json: ["id": "2311", "image_url":"blah", "image_versions": ["normalized", "large"]])!
        let artwork = Artwork(json: ["id": "21314", "title":"Hello work", "medium" : "Code"] )!

        let aBitAgo = NSDate(timeIntervalSinceNow: -36546278)
        let aBitInTheFuture = NSDate(timeIntervalSinceNow: 3654678)
        return Show(id: "213234234", name: "Stubby Show", partner: partner, pressRelease: nil, showDescription: nil, startDate: aBitAgo, endDate: aBitInTheFuture, installShots: [image], artworks: [artwork], imageFormatString: "", imageVersions: [""])
    }
}

let dateShowFormatter = ISO8601DateFormatter()

extension Show: Decodable {
    init?(json: JSON) {

        guard
            let idValue: String = "id" <~~ json,
            let nameValue: String = "name" <~~ json,
            let partnerValue: Partner = "partner" <~~ json
        else {
            return nil
        }

        id = idValue
        name = nameValue
        partner = partnerValue

        if
            let start: String = "start_at" <~~ json,
            let end: String = "end_at" <~~ json {
            startDate = dateShowFormatter.dateFromString(start)
            endDate = dateShowFormatter.dateFromString(end)

        } else {
            startDate = nil
            endDate = nil
        }

        pressRelease = "press_release" <~~ json
        showDescription = "description" <~~ json

        artworks = []
        installShots = []

        // ImageURLThumbnailable conformance
        if
            let imageFormatStringValue: String = "image_url" <~~ json,
            let imageVersionsValue: [String] = "image_versions" <~~ json {
                imageFormatString = imageFormatStringValue
                imageVersions = imageVersionsValue
        } else {
            imageFormatString = ""
            imageVersions = []
        }
    }
}

extension Show: ShowCollectionViewCellShowType {
    var partnerName: String {
        return partner.name
    }
}

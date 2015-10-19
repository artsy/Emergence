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

    var artworks: [Artworkable]

    var locationOneLiner: String?

    var imageFormatString: String
    var imageVersions: [String]

    var hasInstallationShots: Bool

    static func stubbedShow() -> Show {
        let partner = Partner(json:["id": "2311", "name":"El Partner"])!
        let artwork = Artwork(json: ["id": "21314", "title":"Hello work", "medium" : "Code"] )!

        let aBitAgo = NSDate(timeIntervalSinceNow: -36546278)
        let aBitInTheFuture = NSDate(timeIntervalSinceNow: 3654678)

        let description = "Samuel Freeman is pleased to present 'Relief,' Erin Morrison’s debut solo exhibition. Working with plaster, paint, and fabric, Morrison creates highly tactile surfaces that exist somewhere between painting and sculpture—as relief."

        let press = "Here’s what happened: You meet someone and play them your current favourite song, only to find out that it’s their favourite, too. Yes! Then you listen to it forever – or at least for six hours. If you don’t just have a weakness for pop music, but also for melancholy, and if you’re also a visual artist called Ragnar Kjartansson, then you might ask the band (in this case, The National), whether they would like to play the song (in this case, “Sorrow”) in New York’s MoMA PS1 non-stop for six consecutive hours – and then you make a film about the whole thing. This is the impact of these six hours: Exhaustion sets in, the song begins to change under the weight of time and the musicians begin to experiment cautiously. There are clashes and friction between pathos and irony, trance-like states set in and break off, until a new, collective experience between emotion and reflection, of presence and duration becomes possible. And if you prefer, you could also simply hear and see a literally wonderful concert.\n\n\nHere’s what happened: You meet someone and play them your current favourite song, only to find out that it’s their favourite, too. Yes! Then you listen to it forever – or at least for six hours. If you don’t just have a weakness for pop music, but also for melancholy, and if you’re also a visual artist called Ragnar Kjartansson, then you might ask the band (in this case, The National), whether they would like to play the song (in this case, “Sorrow”) in New York’s MoMA PS1 non-stop for six consecutive hours – and then you make a film about the whole thing. This is the impact of these six hours: Exhaustion sets in, the song begins to change under the weight of time and the musicians begin to experiment cautiously. There are clashes and friction between pathos and irony, trance-like states set in and break off, until a new, collective experience between emotion and reflection, of presence and duration becomes possible. And if you prefer, you could also simply hear and see a literally wonderful concert.\n\n      “A Lot of Sorrow” took place at MoMA PS1, as part of Sunday Sessions. A joint project by KÖNIG GALERIE and Foreign Affairs - Festivalt."

        let location = "Huddersfield, UK"
        return Show(id: "213234234", name: "Stubby Show", partner: partner, pressRelease: press, showDescription: description, startDate: aBitAgo, endDate: aBitInTheFuture, artworks: [artwork], locationOneLiner: location, imageFormatString: "", imageVersions: [""], hasInstallationShots: true)
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

        if let imageCount: Int = "images_count" <~~ json {
            hasInstallationShots = imageCount > 0
        } else {
            hasInstallationShots = false
        }

        locationOneLiner = Show.locationOneLinerFromJSON(json)

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

    // Gets a one liner to describe the show
    // taking details out of a JSON dictionary
    static func locationOneLinerFromJSON(json: JSON) -> String? {
        let location:JSON? = "location" <~~ json
        if let location = location {
            
            // City, street
            if let city: String = "city" <~~ location,
               let address: String = "address" <~~ location {
                    return "\(city), \(address)"
            }

            // City
            if let city: String = "city" <~~ location {
                return city
            }
        }

        let fairLocation:JSON? = "fair_location" <~~ json
        let fairJSON:JSON? = "fair" <~~ json

        // Without local location or fair data, we can't continue
        guard let fair:JSON = fairJSON else { return nil }

        // Fair, booth #
        if let fairLocation = fairLocation {
            if let name = fair["name"] as? String,
               let loc = fairLocation["display"] as? String {
                return "\(name), \(loc)"
            }
        }

        // Fair
        return fair["name"] as? String
    }
}

extension Show: ShowCollectionViewCellShowType {
    var partnerName: String {
        return partner.name
    }
}

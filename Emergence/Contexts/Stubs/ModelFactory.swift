import UIKit

class ModelFactory: NSObject {
    static func randomName() -> String {

        // TODO: Ask Alloy for some gender ambiguous dutch names
        let first = ["Jesse", "Sam", "Chris", "Ash", "Danny"][Int(arc4random_uniform(5))]
        let second = ["Smith", "Jones", "Potter", "Brown", "Hirst"][Int(arc4random_uniform(5))]
        return "\(first) \(second)"
    }

    static func randomID() -> String {
        let i = arc4random_uniform(5);
        return ["1231432", "3242352", "3225235", "43534634", "4536475"][Int(i)]
    }
    
    static func image() -> Imageable {
        return Image(
            id: randomID(),
            imageFormatString: "Hi",
            imageVersions: ["Hi"],
            imageSize: CGSize(width: 45, height: 60),
            aspectRatio: 1,
            baseURL: NSURL(string: "https://image.com")!,
            tileSize: 512,
            maxTiledHeight: 1,
            maxTiledWidth: 1,
            maxLevel: 1,
            isDefault: true
        )
    }
    
    static func artist() -> Artistable {
        return Artist(id: randomID(), name: randomName() )
    }
    
    static func artwork() -> Artworkable {
        let artists = [artist()]
        
        return Artwork(id: randomID(), title: "There", medium: "bread", artists:artists, images:[image()])
    }
    
    static func show() -> Showable {
        return Show(name: randomName(), installShots: [image()], artworks: [artwork()], thumbnailImageFormatString: "", thumbnailImageVersions: [""])
    }
    
    static func location() -> Location {
        return Location(shows: [show()])
    }
}

import JavaScriptCore
import UIKit

struct LocationsHost {

    let featured = ["new-york", "london", "los-angeles", "paris", "berlin", "miami", "san-francisco", "hong-kong", "milan", "sao-paulo", "tokyo"]
    var cities = [Location]()

    // Gnarly function to grab locations from local JSON cache
    init? () {
        let bundle = NSBundle.mainBundle()
        guard let citiesPath = bundle.pathForResource("cities", ofType: "js") else { return nil }

        do {
            let data = try NSData(contentsOfFile: citiesPath, options: [])
            guard let citiesJSON = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [[String : AnyObject]] else { return }

            self.cities = citiesJSON.flatMap { dict in
                guard let
                    name = dict["name"] as? String,
                    slug = dict["slug"] as? String,
                    location = dict["coords"] as? [Double]

                else { return nil }

                return Location(name: name, slug: slug, coords: location)
            }

        } catch {
            return nil
        }
    }

    subscript(locationSlug: String) -> Location? {
        get {
            for location in cities {
                if location.slug == locationSlug {
                    return location
                }
            }
            return nil
        }
    }
}

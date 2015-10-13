import JavaScriptCore
import UIKit

struct LocationsHost {

    let featured = ["new-york", "london", "los-angeles", "paris", "berlin", "miami", "san-francisco", "hong-kong", "milan", "sao-paulo", "tokyo"]
    let cities: [Location]

    // Gnarly function to grab locations from local JSON cache
    init? () {
        let bundle = NSBundle.mainBundle()
        guard let citiesPath = bundle.pathForResource("cities", ofType: "js")  else {
            return nil
        }

        do {
            var citiesString = try String(contentsOfFile: citiesPath, encoding: NSUTF8StringEncoding)
            citiesString = citiesString.stringByReplacingOccurrencesOfString("module.exports", withString: "var cities")

            let js = JSContext()
            js.evaluateScript(citiesString)

            let value = js.evaluateScript("cities")
            var mutCities = [Location]()
            for city in value.toArray() {
                if let obj = city as? Dictionary<String, AnyObject>   {
                    guard let name = obj["name"] as? String, let slug = obj["slug"] as? String, let location = obj["coords"] as? [Double] else {
                        continue
                    }

                    let l = Location(name: name, slug: slug, coords: location)
                    mutCities.append(l)
                }
            }
            cities = mutCities

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

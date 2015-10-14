import Foundation
import TVServices

// Uh Oh
// Let's document some bad practices here made for time/complexity tradeoffs:
//
//   - Hardcoding the link to the xapp/featured shows rather than taking it from emergence
//   - Copying the files from Pods for Keys/ArtsyNetworkOperator
//
// Other than that, not too bad. ./

// So this is an OS extension ran by the OS when we send a notification with the string
// TVTopShelfItemsDidChangeNotification - which we do on launch in the app

// For debugging: you run the extension then launch emergence, it won't load properly
//                so you then switch targets to Emergence and your app will run in the
//                background. Breakpoints/Exceptions will work then :+1:.

class ServiceProvider: NSObject, TVTopShelfProvider {

    var topShelfStyle: TVTopShelfContentStyle {
        return .Sectioned
    }

    lazy var featuredShowsWrapper: TVContentItem = {
        let wrapperID = TVContentIdentifier(identifier: "featured-shows", container: nil)!
        let wrapperItem = TVContentItem(contentIdentifier: wrapperID)!
        wrapperItem.title = "Featured Shows"
        return wrapperItem
    }()

    var topShelfItems: [TVContentItem] {
        var items:[TVContentItem] = []
        let semaphore = dispatch_semaphore_create(0)

        let keys = EmergenceKeys()
        Networking.auth(keys) { (token, error) -> () in

            // No auth, no go
            if error != nil {
                dispatch_semaphore_signal(semaphore)
                return print("Error: \(error)")
            }

            // Setup the networking stack
            let networkOp = ArtsyNetworkOperator()
            let url = NSURL(string: "https://api.artsy.net/api/v1/set/530ebe92139b21efd6000071/items")!

            // Make sure we apply our new xapp token
            let request = NSMutableURLRequest(URL: url)
            request.setValue(token!, forHTTPHeaderField: "X-Xapp-Token")

            let _ = networkOp.JSONTaskWithRequest(request, success: { request, response, json in

                // When this scope wraps up we can say we're done
                defer { dispatch_semaphore_signal(semaphore) }

                // This is a collection of shows raw JSON
                guard let showDicts = json as? [[String:AnyObject]] else {
                    return print("Could not convert the JSON to an array")
                }

                self.featuredShowsWrapper.topShelfItems = showDicts.map(self.showDictToWrapper)
                items = [self.featuredShowsWrapper]

            }, failure: { (request, response, error, json) in

                // Perhaps the set has moved? but can't do much atm
                dispatch_semaphore_signal(semaphore)
            })
        }

        // wait for the above semaphore to complete before we go on
        // if it locks forever, it's safe to assume apple's watchdog
        // will kill the app
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return items
    }

    /// NSDict of a Show -> TVContentItem
    func showDictToWrapper(show: [String:AnyObject]) -> TVContentItem {
        let identifier = TVContentIdentifier(identifier: show["name"] as! String, container: self.featuredShowsWrapper.contentIdentifier)!
        let contentItem = TVContentItem(contentIdentifier: identifier)!

        // looks like: [___]
        // they only support poster: [] and square [_]
        // this seemed like the most reasonable fit

        contentItem.imageShape = .HDTV

        // So many `!` - but hey, swift hates JSON.
        let showTitle = show["name"] as! String
        let showID = show["id"] as! String
        let partnerName = show["partner"]!["name"] as! String

        contentItem.title = "\(showTitle) - \(partnerName)"
        contentItem.imageURL = thumbnailForShowDict(show)
        contentItem.displayURL = NSURL(string:"artsyshows://shows/\(showID)")
        return contentItem
    }

    /// NSDict of Show -> NSURL for the thumbnail
    /// prioritising larger thumbnails first
    func thumbnailForShowDict(show: [String:AnyObject]) -> NSURL {
        let imageFormat:String = show["image_url"] as! String
        let formats = show["image_versions"]!
        var thumbnailVersion: String?

        for potentialThumbnail in ["featured", "larger", "large"] where formats.containsObject(potentialThumbnail) {
            if thumbnailVersion == nil { thumbnailVersion = potentialThumbnail }
        }

        var url = imageFormat.stringByReplacingOccurrencesOfString("{?image_version}", withString: thumbnailVersion!)
        url = url.stringByReplacingOccurrencesOfString(":version", withString: thumbnailVersion!)
        return NSURL(string: url)!
    }
}


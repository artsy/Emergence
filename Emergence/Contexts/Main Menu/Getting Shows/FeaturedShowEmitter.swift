import UIKit

class FeaturedShowEmitter: NSObject, ShowEmitter {
    let network: ArtsyProvider<ArtsyAPI>
    let title: String

    init(title:String, initialShows:[Show], network: ArtsyProvider<ArtsyAPI>) {
        self.network = network
        self.title = title
        self.shows = initialShows
    }

    var updateBlock: EmitterUpdateCallback?
    func onUpdate( callback: EmitterUpdateCallback ) {
        updateBlock = callback
    }

    var shows:[Show] = [] {
        didSet {
            updateBlock?(emitter:self, shows: shows, before: [], delta: shows)
        }
    }

    func showAtIndexPath(index: NSIndexPath) -> Show {
        precondition(index.row < shows.count)
        return shows[index.row]
    }

    var numberOfShows: Int {
        return shows.count
    }

    func getShows() {
        network.request(.FeaturedShows).mapSuccessfulHTTPToObjectArray(Show).subscribe(next: { shows in
            self.shows = shows
        })
    }
    
}
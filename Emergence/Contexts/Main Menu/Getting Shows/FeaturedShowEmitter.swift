import UIKit

class FeaturedShowEmitter: NSObject, ShowEmitter {
    let network: ArtsyProvider<ArtsyAPI>
    let title: String

    init(title:String, initialShows:[Show], network: ArtsyProvider<ArtsyAPI>) {
        self.network = network
        self.title = title
        self.shows = initialShows
    }

    var updateBlock: ((shows:[Show]) -> ())?
    func onUpdate( callback: (shows:[Show]) -> () ) {
        updateBlock = callback
    }

    var shows:[Show] = [] {
        didSet {
            updateBlock?(shows: shows)
        }
    }

    func showAtIndexPath(index: NSIndexPath) -> Show {
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
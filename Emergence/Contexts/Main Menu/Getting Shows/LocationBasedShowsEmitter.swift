import UIKit
import RxSwift

class LocationBasedShowEmitter: NSObject, ShowEmitter {
    let network: ArtsyProvider<ArtsyAPI>
    let location: Location
    let title: String

    var page = 1
    var networking = false
    var done = false
    let jsonScheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "json")

    init(location:Location, network: ArtsyProvider<ArtsyAPI>) {
        self.network = network
        self.location = location
        self.title = location.name
    }

    var updateBlock: EmitterUpdateCallback?
    func onUpdate(callback: EmitterUpdateCallback) {
        updateBlock = callback
    }

    var shows:[Show] = []

    func showAtIndexPath(index: NSIndexPath) -> Show {
        let showIndex = min(index.row, shows.count)
        return shows[showIndex]
    }

    var numberOfShows: Int {
        print("asked for number of shows (\(title)) \(shows.count)")
        return shows.count
    }

    func getShows() {
        if networking || done { return }

        print("Getting \(title) at page \(page)")
        networking = true

        let pageAmount = 25
        let coords = location.coordinates()
        let showInfo = ArtsyAPI.RunningShowsNearLocation(page: page, amount: pageAmount, lat: coords.lat, long: coords.long)
        let request = network.request(showInfo).observeOn(jsonScheduler).mapSuccessfulHTTPToObjectArray(Show).observeOn(MainScheduler.sharedInstance)

        request.subscribe(next: { newShows in
            self.done = newShows.count < pageAmount
            self.page += 1
            self.networking = false

            let before: [Show] = self.shows
            let delta = newShows.filter { $0.hasInstallationShots && $0.hasArtworks }
            self.shows = self.shows + delta

            if self.shows.isEmpty { print("Got no shows for \(self.location.name)") }

            print("did \(self.title) at page \(self.page)")
            self.updateBlock?(emitter:self, shows: self.shows, before: before, delta:delta)

        }, error: { error in
            print("ERROROR \(error)")

        }, completed: nil, disposed: nil)
    }

    func visibleImageURLsForShowsAtLocation() -> [NSURL] {
        return self.shows.prefix(3).map { $0.bestAvailableThumbnailURL() }.flatMap { $0 }
    }

    func imageURLsForShowsAtLocation() -> [NSURL] {
        return self.shows.map { $0.bestAvailableThumbnailURL() }.flatMap { $0 }
    }
}
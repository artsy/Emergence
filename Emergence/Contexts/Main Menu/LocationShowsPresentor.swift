import UIKit

class LocationShowsPresentor: NSObject, UICollectionViewDataSource {

    var shows: [String:[Show]]
    var locationHost: LocationsHost

    let collectionView: UICollectionView

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.locationHost = LocationsHost()!

        self.shows = [:]
        for locationKey in locationHost.featured {
            self.shows[locationKey] = []
        }

        super.init()
        collectionView.dataSource = self
        self.getAboveFoldLocationData()
    }

    func getAboveFoldLocationData() {
        let aboveTheFoldLocationKey = locationHost.featured.first!
        getShowsForKey(aboveTheFoldLocationKey, api: ArtsyProvider<ArtsyAPI>() )
    }

    func getShowsForKey(key: String, api: ArtsyProvider<ArtsyAPI>) {
        guard let location = locationHost[key] else {
            return print("Could not find a location for the key '\(key)'.")
        }

        shows[key] = [Show.stubbedShow(), Show.stubbedShow()]
        collectionView.reloadData()
        
//        let coords = location.coordinates()
//        let showInfo = ArtsyAPI.RunningShowsNearLocation(amount: 5, lat: coords.lat, long: coords.long)
//        api.request(showInfo).mapSuccessfulHTTPToObjectArray(Show).subscribe { (event) in
//            print("OK - got \(event).")
//        }
    }

    func showAtIndexPath(index: NSIndexPath) -> Show {
        let key = locationHost.featured[index.section]
        return shows[key]![index.row]
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return locationHost.featured.count
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = locationHost.featured[section]
        return shows[key]!.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let show = showAtIndexPath(indexPath)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("show", forIndexPath: indexPath) as! ShowCollectionViewCell

        cell.showNameLabel.text = show.name
        cell.partnerNameLabel.text = show.partner.name

        if let thumbnailURL = show.bestAvailableThumbnailURL() {
            cell.imageView.sd_setImageWithURL(thumbnailURL)
        } else {
            print("Could not find a thumbnail for \(show.name) - found \(show.imageVersions)")
        }

        if let start = show.startDate, end = show.endDate {
            cell.ausstellungsdauerLabel.text = start.ausstellungsdauerToDate(end)
        } else {
            cell.ausstellungsdauerLabel.text = ""
        }
        
        return cell
    }
}

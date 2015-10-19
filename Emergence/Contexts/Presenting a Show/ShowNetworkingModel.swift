import RxSwift
import UIKit

func stubImage(path: NSString, ratio: Float) -> Image {
    return Image(json: ["id": "id", "image_url": path, "image_versions": ["featured"], "aspect_ratio": ratio ] )!
}

func stubArtwork(id: String, image: Image, title: String, artist: String) -> Artwork {
    let imageJSON = ["id": "id", "image_url": image.imageFormatString, "image_versions": ["featured"], "aspect_ratio": image.aspectRatio! ]

    return Artwork(json: ["id": id, "title":title, "medium" : "Code", "images" : [imageJSON], "cultural_marker" : artist ] )!
}


struct ShowNetworkingModel {
    let network: ArtsyProvider<ArtsyAPI>
    let show: Show

    // MARK: Image Requests / Stubs

    var imageNetworkRequest: Observable<[Image]> {
        let showImages = ArtsyAPI.ImagesForShow(showID: show.id)
        return network.request(showImages).mapSuccessfulHTTPToObjectArray(Image)
    }

    let images: [Image] = {
        let stubPath = NSBundle.mainBundle().pathForResource("slide-bg-1.jpg", ofType: nil)!
        let image = stubImage(stubPath, ratio: 0.76)
        let image2 = stubImage(stubPath, ratio: 1)
        let image3 = stubImage(stubPath, ratio: 1.2)
        let image4 = stubImage(stubPath, ratio: 0.4)
        return [image, image2, image3, image4]
    }()

    var imageNetworkFakes: Observable<[Image]>  {
        return BehaviorSubject(value: images)
    }

    // MARK: Artwork Requests / Stubs

    var artworkNetworkRequest: Observable<[Artwork]> {
        let showArtworks = ArtsyAPI.ArtworksForShow(partnerID: show.partner.id, showID: show.id)
        return network.request(showArtworks).mapSuccessfulHTTPToObjectArray(Artwork)
    }

    let artworks: [Artwork] = {
        let stubPath = NSBundle.mainBundle().pathForResource("slide-bg-2.jpg", ofType: nil)!

        var image = stubImage(stubPath, ratio: 0.4)
        let artwork = stubArtwork("as1sda", image:image, title: "Work 1", artist: "Some person")

        image = stubImage(stubPath, ratio: 1)
        let artwork2 = stubArtwork("as1s23da", image:image, title: "Work 2", artist: "Another person")

        image = stubImage(stubPath, ratio: 0.8)
        let artwork3 = stubArtwork("as1231sda", image:image, title: "Work 3", artist: "That person")

        return [artwork, artwork2, artwork3]
    }()

    var artworkNetworkFakes: Observable<[Artwork]>  {
        return BehaviorSubject(value: artworks)
    }

}

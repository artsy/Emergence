import UIKit
import RxSwift
import Moya
import Gloss

class ShowViewController: UIViewController {
    var index = -1
    let dispose = DisposeBag()
    var show: Show!

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPreviewImage: UIImageView!
    @IBOutlet weak var showDescription: UILabel!

    override func viewDidLoad() {
        precondition(self.show != nil, "you need a show to laod the view controller");
        precondition(self.appViewController != nil, "you need an app VC");

        super.viewDidLoad()

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }


        // Give a whiter BG
        let white = UIView(frame: view.bounds)
        white.backgroundColor = UIColor(white: 1, alpha: 0.5)
        view.addSubview(white)
        view.sendSubviewToBack(white)

        let network = appVC.context.network
        let showArtworks = ArtsyAPI.ArtworksForShow(partnerID: show.partner.id, showID: show.id)
        network.request(showArtworks).mapSuccessfulHTTPToObjectArray(Artwork)
            .subscribe(next: { artworks in
                print(artworks)
                
            }, error: { error in
                print("ERROROR \(error)")
            }, completed: nil, disposed: nil)

    }

    func showDidLoad(show: Show) {
        showTitleLabel.text = show.name
    }
}

import UIKit
import RxSwift
import Moya
import Gloss

class ShowViewController: UIViewController {
    var index = -1
    let dispose = DisposeBag()

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPreviewImage: UIImageView!
    @IBOutlet weak var showDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Give a whiter BG
        let white = UIView(frame: view.bounds)
        white.backgroundColor = UIColor(white: 1, alpha: 0.5)
        view.addSubview(white)
        view.sendSubviewToBack(white)

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

//        let network = appVC.context.network

//        let showInfo = ArtsyAPI.ShowInfo(showID: "4ea19ee97bab1a0001001908")
//        network.request(showInfo).mapSuccessfulHTTPToObject(Show).subscribe(next: { showObject in
//            let show = showObject as! Show
//            self.showDidLoad(show)
//
//        }, error: { error in
//            print("ERROROR \(error)")
//        }, completed: nil, disposed: nil)

    }

    func showDidLoad(show: Show) {
        showTitleLabel.text = show.name
    }
}

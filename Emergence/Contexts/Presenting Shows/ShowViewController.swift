import UIKit
import RxSwift
import Moya
import Gloss
import Representor

class ShowViewController: UIViewController {
    let dispose = DisposeBag()

    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var showPreviewImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appVC = self.appViewController else {
            print("you need an app VC")
            return
        }

        let network = appVC.context.network

        let showInfo = ArtsyAPI.ShowInfo(showID: "4ea19ee97bab1a0001001908")
        network.request(showInfo).mapSuccessfulHTTPToObject(Show).subscribe(next: { showObject in
                let show = showObject as! Show
                self.showDidLoad(show)

            }, error: { error in
                print("ERROROR \(error)")
            }, completed: nil, disposed: nil)

    }

    func showDidLoad(show: Show) {
        showTitleLabel.text = show.name
    }
}

enum ORMError : ErrorType {
    case ORMNoRepresentor
    case ORMNotSuccessfulHTTP
    case ORMNoData
    case ORMCouldNotMakeObjectError
}

extension Observable {
    func mapSuccessfulHTTPToObject(classType: Decodable.Type) -> Observable<Decodable> {

        func resultFromJSON(object:[String: AnyObject], classType: Decodable.Type) -> Decodable? {
            return classType.init(json: object)
        }

        return map { representor in
            guard let response = representor as? MoyaResponse else {
                throw ORMError.ORMNoRepresentor
            }

            // Allow successful HTTP codes
            if ((200...209) ~= response.statusCode) == false {
                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
                    print(json)
                }
                throw ORMError.ORMNotSuccessfulHTTP
            }

            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }

                guard let obj = resultFromJSON(json, classType: classType)  else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }

                return obj

            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
            throw ORMError.ORMCouldNotMakeObjectError
        }
    }
}
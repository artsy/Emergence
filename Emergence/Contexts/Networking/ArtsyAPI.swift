import Foundation
import RxSwift
import Moya
import Alamofire

enum ArtsyAPI {
    case XApp
    case ShowInfo(showID:String)
    case UpcomingShowsNearLocation(lat:String, long: String)
    case RunningShowsNearLocation(amount: Int, lat: String, long: String)
    case PastShowsNearLocation(lat: String, long: String)
    case ArtworksForShow(partnerID: String, showID: String)
    case ImagesForShow(showID: String)
}

extension ArtsyAPI : MoyaTarget {

    var base: String { return AppSetup.sharedState.useStaging ? "https://stagingapi.artsy.net" : "https://api.artsy.net" }
    var baseURL: NSURL { return NSURL(string: base)! }

    var parameters: [String: AnyObject] {
        switch self {

        case .XApp:
            return [
                "grant_type": "credentials"
            ]

        case .UpcomingShowsNearLocation(let lat, let long):
            return sortCriteriaAt("\(lat),\(long)", [
                "status": "upcoming",
                "sort": "start_at"
            ])

        case .RunningShowsNearLocation(let amount, let lat, let long):
            return sortCriteriaAt("\(lat),\(long)", [
                "size" : String(amount),
                "status": "running",
                "sort": "end_at",
                "total_count" : true
            ])

        case .PastShowsNearLocation(let lat, let long):
            return sortCriteriaAt("\(lat),\(long)", [
                "status": "running",
                "sort": "end_at",
            ])

        default:
            return [:]
        }
    }

    var method: Moya.Method {
        switch self {
        default:
            return .GET
        }
    }

    // Only kinda guilty. Deal with it.
    var sampleData: NSData {
        switch self {

        default:
            return NSData()

        }
    }

    var path: String {
        switch self {

        case .XApp:
            return "/api/v1/xapp_token"

        case .ShowInfo(let showID):
            return "/api/v1/show/\(showID)"

        case .ArtworksForShow(let partnerID, let showID):
            return "/api/v1/partner/\(partnerID)/show/\(showID)/artworks/"

        case .ImagesForShow(let showID):
            return "/api/v1/show/\(showID)/images"

        case .RunningShowsNearLocation, .UpcomingShowsNearLocation, .PastShowsNearLocation:
            return "/api/v1/shows"
        }
    }

    /// Allows for some defaults in the show nearby queries built to replicate
    /// https://github.com/artsy/force-public/blob/4dc397880f447022be70bae3ecff59867a7a603c/apps/shows/routes.coffee#L30-L41
    ///
    func sortCriteriaAt(near:String, _ diff: [String: AnyObject]) -> [String: AnyObject] {
        var defaults: Dictionary<String, AnyObject> = [
            "near": near,
            "sort": "-start_at",
            "size": 5,
            "displayable": true,
            "at_a_fair": false,
        ]
        for key in diff.keys {
            defaults.updateValue(diff[key]!, forKey: key)
        }
        return defaults
    }

}

// MARK: - Provider setup

class ArtsyProvider<T where T: MoyaTarget> : RxMoyaProvider<T> {
    var authToken: XAppToken

    override init(endpointClosure: MoyaEndpointsClosure = MoyaProvider.DefaultEndpointMapping,
                 endpointResolver: MoyaEndpointResolution = ArtsyProvider.AuthEndpointResolution,
                     stubBehavior: MoyaStubbedBehavior = MoyaProvider.NoStubbingBehavior,
                credentialClosure: MoyaCredentialClosure? = nil,
           networkActivityClosure: Moya.NetworkActivityClosure? = nil,
                          manager: Alamofire.Manager = Alamofire.Manager.sharedInstance) {

                authToken = XAppToken()
                super.init(endpointClosure: endpointClosure, endpointResolver:endpointResolver , stubBehavior: stubBehavior, credentialClosure: credentialClosure, networkActivityClosure: networkActivityClosure, manager: manager)
    }

    // We always use xapp auth, logging in is handled by Artsy_Authentication
    class func AuthEndpointResolution(endpoint: Endpoint<T>) -> NSURLRequest {
        let request = endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": XAppToken().token ?? ""]).urlRequest
        return request
    }
}

// MARK: - Provider support

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

public func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString
}

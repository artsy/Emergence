import Foundation
import RxSwift
import Moya
import Alamofire

enum ArtsyAPI {
    case XApp
    case ShowInfo(showID:String)

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
        }
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

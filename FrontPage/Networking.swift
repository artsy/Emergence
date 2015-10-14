import UIKit

class Networking: NSObject {
    static func auth(keys:EmergenceKeys, completion: (token: String?, error: NSError?)-> () ) {
        let id = keys.artsyAPIClientKey()
        let secret = keys.artsyAPIClientSecret()
        let path = "https://api.artsy.net/api/v1/xapp_token?client_id=\(id)&client_secret=\(secret)"
        let request = NSURLRequest(URL: NSURL(string:path)!)
        let networking = ArtsyNetworkOperator()

        networking.JSONTaskWithRequest(request, success: { request, response, data in
            guard let data = data as? [String:AnyObject] else { return }
            guard let token = data["xapp_token"] as? String else { return }
            completion(token: token, error: nil)

        }, failure: { request, response, error, json in
            completion(token: nil, error: error)
        })

    }
}

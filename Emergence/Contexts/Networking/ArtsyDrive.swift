import Foundation
import Hyperdrive
import Representor

public class ArtsyDrive: Hyperdrive {

    var authToken: String

    public init(token: String) {
        self.authToken = token

        // Hacks around https://groups.google.com/forum/#!topic/artsy-api-developers/z5hKDSLStS8

        HTTPDeserialization.deserializers["application/json"] = HTTPDeserialization.deserializers["application/hal+json"]
        HTTPDeserialization.preferredContentTypes = ["application/json"]
    }

    public func enter(completion: (RepresentorResult -> Void)) {
        enter("https://api.artsy.net:443/api", completion: completion)
    }

    public override func constructRequest(uri: String, parameters: [String : AnyObject]?) -> RequestResult {
        return super.constructRequest(uri, parameters: parameters).map { request in
            print("OK \(authToken)")
            return request
        }
    }

}
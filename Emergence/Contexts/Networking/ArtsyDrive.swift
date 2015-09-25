import Foundation
import Hyperdrive
import Representor

public class ArtsyDrive: Hyperdrive {

    var authToken: String
    var root: Representor<HTTPTransition>

    public init(token: String) {
        self.authToken = token
        self.root = Representor<HTTPTransition>()
        // Hacks around https://groups.google.com/forum/#!topic/artsy-api-developers/z5hKDSLStS8
        HTTPDeserialization.deserializers["application/json"] = HTTPDeserialization.deserializers["application/hal+json"]
        HTTPDeserialization.preferredContentTypes = ["application/json"]
    }

    public func enter(completion: (RepresentorResult -> Void)) {
        enter("https://api.artsy.net:443/api") { result in
            switch result {
            case .Success(let representor):
                self.root = representor

            case .Failure(let error):
                print("There was a problem getting the root: \(error)")
            }

            completion(result)
        }
    }

    public override func constructRequest(uri: String, parameters: [String : AnyObject]?) -> RequestResult {
        return super.constructRequest(uri, parameters: parameters).map { request in
            request.setValue(authToken, forHTTPHeaderField: "X-Xapp-Token")
            return request
        }
    }

}
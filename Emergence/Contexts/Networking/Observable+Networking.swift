import RxSwift
import Gloss
import Moya

enum ORMError : ErrorType {
    case ORMNoRepresentor
    case ORMNotSuccessfulHTTP
    case ORMNoData
    case ORMCouldNotMakeObjectError
}

extension Observable {

    // Returns a curried(?) function that maps the object passed through
    // the observable chain into a class that conforms to Decodable

    func mapSuccessfulHTTPToObject(classType: Decodable.Type) -> Observable<Decodable> {

        func resultFromJSON(object:[String: AnyObject], classType: Decodable.Type) -> Decodable? {
            return classType.init(json: object)
        }

        return map { representor in
            guard let response = representor as? MoyaResponse else {
                throw ORMError.ORMNoRepresentor
            }

            // Allow successful HTTP codes
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
                    print("Got error message: \(json)")
                }
                throw ORMError.ORMNotSuccessfulHTTP
            }

            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }
                return resultFromJSON(json, classType: classType)!
            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
        }
    }

    // Returns a curried(?) function that maps the object passed through
    // the observable chain into a class that conforms to Decodable

    func mapSuccessfulHTTPToObjectArray(classType: Decodable.Type) -> Observable<[Decodable]> {

        func resultFromJSON(object:[String: AnyObject], classType: Decodable.Type) -> Decodable? {
            return classType.init(json: object)
        }

        return map { representor in
            guard let response = representor as? MoyaResponse else {
                throw ORMError.ORMNoRepresentor
            }

            // Allow successful HTTP codes
            guard ((200...209) ~= response.statusCode) else {
                if let json = try? NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [String: AnyObject] {
                    print("Got error message: \(json)")
                }
                throw ORMError.ORMNotSuccessfulHTTP
            }

            do {
                guard let json = try NSJSONSerialization.JSONObjectWithData(response.data, options: .AllowFragments) as? [[String : AnyObject]] else {
                    throw ORMError.ORMCouldNotMakeObjectError
                }

                return json.map { resultFromJSON($0, classType: classType)! }
            } catch {
                throw ORMError.ORMCouldNotMakeObjectError
            }
        }
    }

}
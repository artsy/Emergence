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
                    print("Got error message:")
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
        }
    }
}
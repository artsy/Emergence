/// Encapsulates shared behavior within Image types

protocol Partnerable {
    var id: String { get }
    var name: String { get }
    var profileID: String? { get }
}

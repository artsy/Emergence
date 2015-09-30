struct Location {
    let name: String
    let slug: String
    let coords:[Double]

    /// Returns a lat/long tuple for the ArtsyAPI methods to take
    /// in as the function parameters.
    ///
    func coordinates() -> (lat: String, long: String) {
        return (lat: String(coords[0]), long: String(coords[1]))
    }
}
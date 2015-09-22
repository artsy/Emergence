// Bets on how long this stays as a struct?

struct Artwork: Artworkable {
    let id: String
    let title: String
    let medium: String
    
    let artists: [Artistable]
    let images: [Imageable]
}

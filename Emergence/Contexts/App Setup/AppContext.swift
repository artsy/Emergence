import Artsy_Authentication

/// Imagine that this is what gets DI'd in to most
/// view controllers via the Storyboard

/// I'd expect it to contain the Hyperdrive for example
/// & once there's auth, user references etc.

struct AppContext {
    let network: ArtsyDrive
    let auth: ArtsyAuthentication
}

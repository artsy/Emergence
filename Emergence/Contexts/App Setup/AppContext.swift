import Artsy_Authentication
import Moya

/// Imagine that this is what gets DI'd in to most
/// view controllers via the Storyboard

/// I'd expect it to contain the Hyperdrive for example
/// & once there's auth, user references etc.

struct AppContext {
    let offline = true
    let network: ArtsyProvider<ArtsyAPI>
    let auth: ArtsyAuthentication
}

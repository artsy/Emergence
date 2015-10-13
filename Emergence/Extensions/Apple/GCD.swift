import Foundation

/// Thanks Matt Neuburg
/// http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861

/// Delays execution of a closure by x seconds
func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

/// Recursively runs the check block until completed every delayTime seconds
func delayWhile(delayTime: Double, check: ()->(Bool), closure: ()->()) {
    if check() == true {
        return closure()
    }

    delay(delayTime) { () -> () in
        delayWhile(delayTime, check: check, closure: closure)
    }
}
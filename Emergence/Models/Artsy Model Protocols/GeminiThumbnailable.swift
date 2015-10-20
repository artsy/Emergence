// Gemini is our image processing tool
// because it is inhouse we can use it to provide
// larger thumbnails for images like our install shots

import Foundation

let geminiServerAddress = "d7hftxdivxxvm.cloudfront.net"

protocol GeminiThumbnailable {
    var geminiToken: String? { get }
}

extension GeminiThumbnailable {

    /// Returns a NSURL representing a thumbnail using Gemini to process the image
    /// to the size we want based on the height of the image

    func geminiThumbnailURLWithHeight(height:Int, quality:Int = 85) -> NSURL? {
        guard let token = geminiToken else { return nil }
        let string = "https://\(geminiServerAddress)/?resize_to=height&height=\(height)&quality=\(quality)&token=\(token)"
        return NSURL(string: string)!
    }

    /// Returns a NSURL representing a thumbnail using Gemini to process the image
    /// to the size we want based on the width of the image

    func geminiThumbnailURLWithWidth(width:Int, quality:Int = 85) -> NSURL? {
        guard let token = geminiToken else { return nil }
        let string = "https://\(geminiServerAddress)/?resize_to=width&width=\(width)&quality=\(quality)&token=\(token)"
        return NSURL(string: string)!
    }
}

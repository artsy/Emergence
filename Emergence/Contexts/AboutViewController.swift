import UIKit
import Alamofire

class AboutViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var keyboardAccessoryView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var linkTextField: UITextField!

    @IBOutlet weak var downloadTheAppMessageLabel: UILabel!

    // We deny all attempts to leave the textfield, bwaahhaha

    // ... so we can run some async code, which will then let them leave hopefully.
    //

    var allowExit = false
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {

        // Bail if you have nothing in there, or we're done
        guard let number = textField.text else { return true }
        if allowExit { textField.text = nil; return true }

        activityIndicator.startAnimating()
        errorMessageLabel.text = ""

        sendPhoneNumber(number) { success, message in

            self.activityIndicator.stopAnimating()
            if success {
                self.success()
                self.cancel()
            } else {
                // the twilio message needs cleaning
                let cleanedMessage = message.stringByReplacingOccurrencesOfString("The 'To' number", withString: "")
                self.errorMessageLabel.text = cleanedMessage
            }
        }
        return false
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return allowExit
    }

    override func viewDidLoad() {
        errorMessageLabel.text = ""
        linkTextField.inputAccessoryView = keyboardAccessoryView
    }

    override func viewDidAppear(animated: Bool) {
        allowExit = false
    }

    func success() {
        linkTextField.userInteractionEnabled = false
        linkTextField.text = ""
        downloadTheAppMessageLabel.text = "LINK SENT VIA SMS"
        downloadTheAppMessageLabel.textColor = .whiteColor()
    }

    @IBAction func cancel() {
        allowExit = true
        linkTextField.resignFirstResponder()
    }

    let flareAPIPath = "http://iphone.artsy.net/send_link"

    func sendPhoneNumber(number: String, completion: (completed: Bool, message: String) -> () ) {
        let parameters = ["phone_number": number]
        Alamofire.request(.POST, flareAPIPath, parameters: parameters)
            .responseJSON { request, response, result in
                guard let json = result.value as? [String: AnyObject] else {
                    return completion(completed: false, message: "Could not access Artsy, are you offline?")
                }

                guard let success = json["success"] as? Bool, let message = json["message"] as? String else {
                    return completion(completed: false, message: "We are experiencing difficulties sending to this number.")
                }

                completion(completed: success, message: message)
        }
    }
}
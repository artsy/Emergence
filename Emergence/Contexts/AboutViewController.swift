import UIKit
import Alamofire

class AboutViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var linkTextField: UITextField!
    let messageAccessoryView = CustomInputAccessoryView(title: "Hi")

    // We deny all attempts to leave the textfield, bwaahhaha

    // ... so we can run some async code, which will then let them leave hopefully.
    //

    var allowExit = false
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {

        // Bail if you have nothing in there, or we're done
        guard let number = textField.text else { return true }
        if allowExit { return true }

        sendPhoneNumber(number) { success, message in
            if success {
                self.cancel()
            } else {
                self.messageAccessoryView.titleLabel.text = message
            }
        }
        return false
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return allowExit
    }

    override func viewDidLoad() {
        linkTextField.inputAccessoryView = messageAccessoryView
        messageAccessoryView.cancelButton.addTarget(self, action: "cancel", forControlEvents: .PrimaryActionTriggered)
    }

    func cancel() {
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


/// Something simple to start with, will move into a nib

class CustomInputAccessoryView: UIView {

    let titleLabel = UILabel(frame: CGRect.zero)
    let cancelButton = UIButton(type: .System)

    init(title: String) {
        super.init(frame: CGRect.zero)

        // Setup the label and add it to the view.
        titleLabel.font = UIFont.systemFontOfSize(60, weight: UIFontWeightMedium)
        titleLabel.text = title
        addSubview(titleLabel)

        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.adjustsImageWhenHighlighted = true
        addSubview(cancelButton)

        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let viewsDictionary = ["titleLabel": titleLabel, "button" : cancelButton]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-[button]-|", options: [], metrics: nil, views: viewsDictionary))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel]-60-[button]-|", options: [], metrics: nil, views: viewsDictionary))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

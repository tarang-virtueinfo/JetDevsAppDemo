import UIKit.UIViewController

protocol ViewControllerAlerting {
    func displayMessage(message: String,
                           action: (() -> Void)?,
                           controller: UIViewController?)
}

extension ViewControllerAlerting where Self: UIViewController {
    
    func displayMessage(title: String,
                        acceptTitle: String = "OK",
                        message: String,  action: (() -> Void)? = nil,
                        controller: UIViewController? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acceptTitle, style: .default, handler: { _ in
            action?()
        }))
        alert.view.accessibilityIdentifier = "UIAlertController"
        if let controller = controller {
            controller.present(alert, animated: true, completion: nil)
        } else {
            navigationController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func displayMessage(message: String,
                        action: (() -> Void)? = nil,
                        controller: UIViewController? = nil) {
        displayMessage(title: "", acceptTitle: "OK", message: message, action: action, controller: controller)
    }
    
}

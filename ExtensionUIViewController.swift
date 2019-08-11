import Foundation
import UIKit
extension UIViewController {
    func basicAlert(title:String,message:String,buttonTitle:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: buttonTitle, style: .default) { (action:UIAlertAction) in
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}

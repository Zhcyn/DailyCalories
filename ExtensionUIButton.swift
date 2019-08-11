import UIKit
extension UIButton{
func animateImageChange(newImage:UIImage) {
    UIView.transition(with: self, duration: 0.4, options: .transitionFlipFromTop, animations: {
        self.setImage(newImage, for: .normal)
    }, completion: { _ in
        print("Completed animation")
    })
}
}

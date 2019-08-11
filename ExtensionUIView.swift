import Foundation
import UIKit
extension UIView {
    func jitter() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint.init(x:self.center.x - 5.0, y:self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint.init(x:self.center.x + 5.0, y:self.center.y))
        layer.add(animation, forKey: "position")
    }
    func flash(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }) {(animationComplete) in
            if animationComplete == true {
                UIView.animate(withDuration: duration, delay: 1.0, options: .curveEaseOut, animations: {
                    self.alpha = 0.0 }, completion:nil)
            }
        }
    }
    func rounded(){
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
    }
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

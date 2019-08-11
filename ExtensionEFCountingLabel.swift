import Foundation
import UIKit
import EFCountingLabel
extension EFCountingLabel{
    func add(_ value:Int){
    let cals = Double(self.text!)
    let calsFloat = CGFloat(cals!)
    self.countFrom(calsFloat, to: calsFloat + CGFloat(value), withDuration: 0.5)
    }
    func subtract(_ value:Int){
        let cals = Double(self.text!)
        let calsFloat = CGFloat(cals!)
        self.countFrom(calsFloat, to: calsFloat - CGFloat(value), withDuration: 0.5)
    }
}

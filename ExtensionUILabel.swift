import UIKit
extension UILabel {
    func setPositiveNegativeColor(){
        guard let value = Double(self.text!) else {return}
        if(value >= 0){self.textColor = #colorLiteral(red: 0.01095554326, green: 0.4815165401, blue: 0.2025072575, alpha: 1)} else {self.textColor = #colorLiteral(red: 0.859279573, green: 0, blue: 0.1329188049, alpha: 1)}
    }
    func attributedNegativePositive(mainString:String,stringToColor:String){
        guard let stringInt = Int(stringToColor.trim()) else {return}
        let range = (mainString as NSString).range(of: stringToColor)
        let attribute = NSMutableAttributedString.init(string: mainString)
        let color = stringInt >= 0 ? #colorLiteral(red: 0.01095554326, green: 0.4815165401, blue: 0.2025072575, alpha: 1) : #colorLiteral(red: 0.859279573, green: 0, blue: 0.1329188049, alpha: 1)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: range)
        self.attributedText = attribute
            }
    func attributedColor(mainString:String,stringToColor:String,color:UIColor){
        let range = (mainString as NSString).range(of: stringToColor)
        let attribute = NSMutableAttributedString.init(string: mainString)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: range)
        self.attributedText = attribute
    }
}

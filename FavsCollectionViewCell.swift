import UIKit
class FavsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    override func awakeFromNib() {
        self.addRoundedCorners()
    }
    func addRoundedCorners(){
        self.layer.cornerRadius = self.frame.height/10
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
}

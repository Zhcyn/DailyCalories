import UIKit
class Singleton {
    static let sharedInstance : Singleton = {
        let instance = Singleton()
        return instance
    }()
    var term : String?
    var pickedFood:String?
    var pickedCalories:Double?
    var pickedStartingDate: Date?
    var pickedEndingDate:Date?
    var proUser = false
   }

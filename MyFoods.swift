import UIKit
import RealmSwift
class MyFoods: Object {
    @objc dynamic var name = ""
    @objc dynamic var calories = 0.0
    @objc dynamic var location = ""
    @objc dynamic var favourite = false
    @objc dynamic var protein = 0.0
    @objc dynamic var carbs = 0.0
    @objc dynamic var fat = 0.0
}

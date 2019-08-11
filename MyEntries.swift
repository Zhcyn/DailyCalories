import UIKit
import RealmSwift
class MyEntries: Object {
    @objc dynamic var date = Date()
    @objc dynamic var calories = 0.0
    @objc dynamic var name = ""
    @objc dynamic var quantity = 0.0
    @objc dynamic var location = ""
 }

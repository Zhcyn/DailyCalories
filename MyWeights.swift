import UIKit
import RealmSwift
class MyWeights: Object {
    @objc dynamic var date = Date()
    @objc dynamic var weight = 0.0
    @objc dynamic var comments = ""
}

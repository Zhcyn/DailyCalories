import Foundation
import UIKit
import RealmSwift
class RealmHelper{
    static func getNumberOfFoods() -> Int {
        let realm = try! Realm()
        let foodsArray =  realm.objects(MyFoods.self).sorted(byKeyPath: "name", ascending: true)
        return foodsArray.count
    }
}

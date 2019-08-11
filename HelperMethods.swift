import UIKit
import RealmSwift
class HelperMethods: NSObject {
    static func getUIntValueFromHex(hex:String) -> UInt?{
        if let hexValue = UInt(String(hex.suffix(6)), radix: 16) {
            return hexValue
        }
        return nil
    }
    static func convertDateToString(myDate:Date, format:String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ")-> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: myDate)
        return dateString
    }
    static func convertStringToDate(myString: String, format: String = "dd/MM/yyyy HH:mm")-> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: myString)!
        return date
    }
    func presentMenu(vc:UIViewController,sender: UIButton){
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Menu")
        vc.present(popController, animated: true, completion: nil)
    }
    static func getDay(date: Date) -> (String,String){
        let realm = try! Realm()
        let start = Calendar.current.startOfDay(for: date)
        let todayEnd: Date = {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        let todaysCals = realm.objects(MyEntries.self).filter("date BETWEEN %@", [start, todayEnd])
        var cal = 0.0
        var ex = 0.0
        for entry in todaysCals{
            if(entry.calories < 0){
                ex -= entry.calories
            }else{
                cal += entry.calories
            }
        }
        return (String(cal),String(ex))
    }
}

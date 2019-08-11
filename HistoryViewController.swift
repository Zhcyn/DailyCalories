import UIKit
import RealmSwift
class HistoryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var myEntriesArray: Results<MyEntries>?
    var currentDate: Date = Date()
    var selectedIndexPath:IndexPath?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = HelperMethods.convertDateToString(myDate: currentDate, format: "dd-MMM-yyyy")
    }
    override func viewDidAppear(_ animated: Bool) {
        getToday()
        tableView.reloadData()
    }
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func getList(){
        let realm = try! Realm()
        myEntriesArray =  realm.objects(MyEntries.self).sorted(byKeyPath: "date", ascending: true)
    }
    func getToday(){
        let realm = try! Realm()
        let start = Calendar.current.startOfDay(for: currentDate)
        let todayEnd: Date = {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            return Calendar.current.date(byAdding: components, to: start)!
        }()
        myEntriesArray = realm.objects(MyEntries.self).filter("date BETWEEN %@", [start, todayEnd]).sorted(byKeyPath: "date", ascending: false)
        self.tableView.reloadData()
    }
    func getLastSevenDays(){
        let realm = try! Realm()
        var days:[Date] = []
        for n in 0...6{
            let calendar = Calendar.current
            if let currentDay = calendar.date(byAdding: .day, value: -n, to: Date()){
            let start = Calendar.current.startOfDay(for: currentDay)
            days.append(currentDay)
            }
        }
    }
    func delete(index:Int){
        guard let entries = myEntriesArray else {return}
        let myEntry = entries[index]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(myEntry)
            self.tableView.reloadData()
        }
     }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let entries = self.myEntriesArray else {return 0}
        return entries.count
          }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let entries = myEntriesArray else {return UITableViewCell()}
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! EntryTableViewCell
        let entry = entries[indexPath.row]
        cell.caloriesLabel.text = "\(Int(entry.calories)) calories"
        if(entry.name == ""){
            cell.nameLabel.text = "Unnamed entry"
        }else{
        cell.nameLabel.text = entry.name
        }
        cell.qtyLabel.text = String(entry.quantity)
        cell.timeLabel.text = HelperMethods.convertDateToString(myDate: entry.date ,format: "hh:mm a")
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delete(index: indexPath.row)
        getToday()
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "SegueEditEntries", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueEditEntries" {
            guard let selectedIndexPath = selectedIndexPath else {return}
            guard let myEntriesArray = myEntriesArray else {return}
            let editVC = segue.destination as! EditEntriesViewController
            editVC.entry = myEntriesArray[selectedIndexPath.row]
        }
}
}

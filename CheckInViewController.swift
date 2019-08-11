import UIKit
import RealmSwift
import ChartsRealm
import Charts
import StoreKit
import SCLAlertView
class CheckInViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {
    var myWeightsArray: Results<MyWeights>!{
        didSet{
            allWeightsArray = Array(myWeightsArray).reversed()
        }
    }
    @IBOutlet weak var topBarView: UIView!
    var allWeightsArray:[MyWeights] = []
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var datesView: UIView!
    weak var axisFormatDelegate: IAxisValueFormatter?
    var selectedWeight = MyWeights()
    let dateFormat = simpleDate
    var weightUnit:String = "Kgs"
    var startPicker = UIDatePicker()
    var endPicker = UIDatePicker()
    var startDate:Date = Date().dateBeforeOrAfterFromToday(numberOfDays: -30)
    var endDate:Date = Date()
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let unit = restoreWeightType()
        if(unit == nil){
        promptUserToChooseWeightMetric()
        }
        fromTextField.delegate = self
        toTextField.delegate = self
        startPicker.datePickerMode = .date
        endPicker.datePickerMode = .date
        fromTextField.inputView = startPicker
        toTextField.inputView = endPicker
        setCurrentDateOnPicker()
        fillTextFieldsWithValues()
        getList()
        axisFormatDelegate = self
        chartView.chartDescription?.text = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
     }
    func promptUserToChooseWeightMetric(){
        let defaults = UserDefaults.standard
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Kgs", action: {
            defaults.set("Kgs", forKey: "weight_unit")
            self.weightUnit = "Kgs"
            self.updateChartAndTable()
            })
        alert.addButton("Lbs", action: {
            defaults.set("Lbs", forKey: "weight_unit")
            self.weightUnit = "Lbs"
            self.updateChartAndTable()
            })
        alert.addButton("Cancel", backgroundColor: ORANGE, action: {
            print("user cancelled")
            })
        let value = HelperMethods.getUIntValueFromHex(hex: "3D85A9")!
        alert.showSuccess("Choose your weight unit", subTitle: "", colorStyle: value, animationStyle: .topToBottom)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getList()
        updateChartAndTable()
        if let unit = restoreWeightType(){
            weightUnit = unit
        }
    }
    func restoreWeightType() -> String? {
        let defaults = UserDefaults.standard
        let weightUnit = defaults.string(forKey: "weight_unit")
        return weightUnit
    }
    func setCurrentDateOnPicker(){
        startPicker.setDate(startDate, animated: false)
        endPicker.setDate(endDate, animated: false)
    }
    func updateChartAndTable(){
        updateChartWithData()
        allWeightsArray = myWeightsArray.reversed()
        tableView.reloadData()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        getList()
        fillTextFieldsWithValues()
    }
    func updateChartWithData() {
        var dataEntries: [ChartDataEntry] = []
        let weights = getWeightsFromDatabase()
        for i in 0..<weights.count {
            let timeIntervalForDate: TimeInterval = weights[i].date.timeIntervalSince1970
            let dataEntry = ChartDataEntry(x: Double(timeIntervalForDate), y: weights[i].weight.roundTo(places: 2))
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Weights")
        chartDataSet.colors = [ORANGE]
        chartDataSet.circleColors = [ORANGE]
        if(dataEntries.count > 20){
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawCircleHoleEnabled = false
        }else{
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.drawCircleHoleEnabled = true
        }
        let chartData = LineChartData(dataSet: chartDataSet)
        chartData.setDrawValues(false)
        chartView.data = chartData
        chartView.gridBackgroundColor = NSUIColor.blue
        chartView.chartDescription?.text = ""
        let xaxis = chartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.setLabelCount(3, force: true)
    }
    func getWeightsFromDatabase() -> Results<MyWeights> {
        do {
            let realm = try Realm()
            return realm.objects(MyWeights.self).filter("date BETWEEN %@", [startDate, endDate]).sorted(byKeyPath: "date", ascending: true)
         } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    func fillTextFieldsWithValues(){
        fromTextField.text = startDate.convertDateToString(format: dateFormat)
        toTextField.text = endDate.convertDateToString(format: dateFormat)
    }
    @objc func addTapped(){
        presentAlert()
    }
    @IBAction func addWeight(_ sender: UIButton) {
        addTapped()
    }
    @IBAction func calendarAction(_ sender: UIButton) {
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func presentAlert(){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        let value = HelperMethods.getUIntValueFromHex(hex: "3D85A9")!
        let nameText = alertView.addTextField("Weight")
        nameText.keyboardType = .decimalPad
        alertView.addButton("Add") {
            let foodName = nameText.text
            if let w = foodName {
                if let weightDouble = Double(w){
                    self.addNewWeight(weight: weightDouble)
                    self.getList()
                }
            }
        }
        alertView.addButton("Cancel", backgroundColor: ORANGE, action: {})
        alertView.showSuccess("New weight", subTitle: "", colorStyle: value)
    }
    func delete(index:Int){
        let myWeight = allWeightsArray[index]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(myWeight)
            updateChartAndTable()
        }
    }
    @IBAction func menuAction(_ sender: UIButton) {
        HelperMethods().presentMenu(vc: self, sender: sender)
    }
    func presentMenu(sender: UIButton){
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Menu")
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = self.view
        popController.popoverPresentationController?.sourceRect = sender.bounds
        self.present(popController, animated: true, completion: nil)
    }
    func getList(){
        startDate = startPicker.date.startOfDay
        endDate = endPicker.date.endOfDay!
        let realm = try! Realm()
            myWeightsArray = realm.objects(MyWeights.self).filter("date BETWEEN %@", [startDate, endDate]).sorted(byKeyPath: "date", ascending: true)
            allWeightsArray = Array(myWeightsArray)
        if(allWeightsArray.count == 10 || allWeightsArray.count == 100){
         requestReview()
        }
            self.updateChartAndTable()
    }
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
        }
    }
    func addNewWeight(weight: Double){
        let myWeight = MyWeights()
        myWeight.weight = weight
        myWeight.date = Date()
        let realm = try! Realm()
        try! realm.write {
            realm.add(myWeight)
        }
        getList()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allWeightsArray.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WeightTableViewCell
        let weight = allWeightsArray[indexPath.row]
        cell.dateLabel.text = HelperMethods.convertDateToString(myDate: weight.date ,format: "MMM d, yyyy\n h:mm a")
        cell.weightLabel.text = "\(weight.weight.roundTo(places: 2)) \(weightUnit)"
        cell.commentsLabel.text = weight.comments
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWeight = allWeightsArray[indexPath.row]
        performSegue(withIdentifier: "EditWeightViewController", sender: nil)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delete(index: indexPath.row)
        getList()
        updateChartAndTable()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditWeightViewController" {
            let editWeightVC = segue.destination as! EditWeightViewController
            editWeightVC.weightObject = selectedWeight
        }
    }
}
extension CheckInViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = simpleDate
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

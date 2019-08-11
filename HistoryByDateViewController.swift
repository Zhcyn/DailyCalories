import UIKit
import RealmSwift
class DateStats{
    var date:Date
    var food:Int = 0
    var exercise:Int = 0
    var goal:Int {
        let defaults = UserDefaults()
        return defaults.integer(forKey: "goal_calories")
    }
    var net:Int {
        return food - exercise
    }
    var left:Int{
        return goal - net
    }
    init(date:Date,food:Int,exercise:Int){
        self.date = date
        self.food = food
        self.exercise = exercise
    }
}
class HistoryByDateViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    var arrayOfDates:[Date] = []
    var dictOfDates:[Date:String] = [:]
    var dictOfStats:[Date:String] = [:]
    var dictOfDateStats:[Date:DateStats] = [:]
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var averageLabel: UILabel!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var averageExerciseLabel: UILabel!
    @IBOutlet weak var netLabel: UILabel!
    var currentTextField:UITextField?
    let dateFormat = simpleDate
    @IBOutlet weak var tableView: UITableView!
    var selectedDate = Date()
    var startPicker = UIDatePicker()
    var endPicker = UIDatePicker()
    var startDate:Date = Date().dateBeforeOrAfterFromToday(numberOfDays: -6)
    var endDate:Date = Date()
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        fromTextField.delegate = self
        toTextField.delegate = self
        startPicker.addTarget(self, action: #selector(startDatePickerChanged(sender:)), for: .valueChanged)
        endPicker.addTarget(self, action: #selector(endDatePickerChanged(sender:)), for: .valueChanged)
        startPicker.datePickerMode = .date
        endPicker.datePickerMode = .date
        fromTextField.inputView = startPicker
        toTextField.inputView = endPicker
        setCurrentDateOnPicker()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    @IBAction func menuAction(_ sender: UIButton) {
        HelperMethods().presentMenu(vc: self, sender: sender)
        presentMenu(sender: sender)
    }
    func presentMenu(sender: UIButton){
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Menu")
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender as UIView 
        popController.popoverPresentationController?.sourceRect = sender.bounds
        self.present(popController, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDates()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateDates()
    }
    func setCurrentDateOnPicker(){
            startPicker.setDate(startDate, animated: false)
            endPicker.setDate(endDate, animated: false)
    }
    @objc func startDatePickerChanged(sender: UIDatePicker) {
        sender.datePickerMode = .date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = simpleDate
        let myDate = sender.date
        startDate = myDate
        let selectedDate = dateFormatter.string(from: sender.date)
        fromTextField.text = selectedDate
    }
    @objc func endDatePickerChanged(sender: UIDatePicker) {
        sender.datePickerMode = .date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = simpleDate
        let myDate = sender.date
            endDate = myDate
        let selectedDate = dateFormatter.string(from: sender.date)
            toTextField.text = selectedDate
    }
    func updateDates(){
        setCurrentDateOnPicker()
        fillTextFieldsWithValues()
        getDataFromSelectedDates()
        tableView.reloadData()
    }
    func fillTextFieldsWithValues(){
        fromTextField.text = startDate.convertDateToString(format: dateFormat)
        toTextField.text = endDate.convertDateToString(format: dateFormat)
    }
    @IBAction func selectDates(_ sender: Any) {
        performSegue(withIdentifier: "CalendarView", sender: nil)
    }
    @IBAction func endedChoosingDate(_ sender: UITextField) {
        if(toTextField.text != "" && fromTextField.text != ""){
        }
    }
    @IBAction func clearAction(_ sender: Any) {
        startDate = Date().dateBeforeOrAfterFromToday(numberOfDays: -6)
        endDate = Date()
        updateDates()
    }
    func calculateAverageCals(){
    }
    func getDayLeft(date:Date) -> Int{
        let newDayDict = HelperMethods.getDay(date: date)
        let newDayCals = newDayDict.0
        let newDayEx = newDayDict.1
        let goalCalories = defaults.integer(forKey: "goal_calories")
        let netCalories:Int = Int(Double(newDayCals)! - Double(newDayEx)!)
        return goalCalories - netCalories
    }
    func colorNumbers(myString:String) -> NSMutableAttributedString{
        let orangeFont = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.4295217991, blue: 0, alpha: 1)]
        let myAttributedString = NSMutableAttributedString()
        for letter in myString.unicodeScalars {
            let myLetter : NSAttributedString
            if CharacterSet.decimalDigits.contains(letter) {
                myLetter = NSAttributedString(string: "\(letter)", attributes: orangeFont)
            } else {
                myLetter = NSAttributedString(string: "\(letter)")
            }
            myAttributedString.append(myLetter)
        }
        return myAttributedString
    }
    func getDataFromSelectedDates(){
        var start = startDate
        arrayOfDates = []
        dictOfDates = [:]
        dictOfStats = [:]
        var totalCals = 0.0
        var totalExercise = 0.0
        var numberOfDays = 0.0
        start = startPicker.date
        endDate = endPicker.date
        while Calendar.current.compare(start, to: endDate, toGranularity: .day) == .orderedAscending || Calendar.current.compare(start, to: endDate, toGranularity: .day) == .orderedSame{
            arrayOfDates.append(start)
            let newDayDict = HelperMethods.getDay(date: start)
            let newDayCals = newDayDict.0
            let newDayEx = newDayDict.1
            let goalCalories = defaults.integer(forKey: "goal_calories")
            let netCalories:Int = Int(Double(newDayCals)! - Double(newDayEx)!)
            let leftCalories:Int = goalCalories - netCalories
            let exerciseDouble = Double(newDayEx)!
            let exerciseInt = Int(exerciseDouble)
            let dayCals = Double(newDayCals)!
            let dayInt = Int(dayCals)
            dictOfDates[start] = "\(dayInt)"
            dictOfStats[start] = "Exercise: \(exerciseInt) Net: \(netCalories) Goal: \(goalCalories) Left: \(leftCalories)  "
            let dateStat = DateStats(date: start, food: dayInt, exercise: exerciseInt)
            dictOfDateStats[start] = dateStat
            start = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            numberOfDays += 1
            totalCals += Double(newDayCals)!
            totalExercise += Double(newDayEx)!
        }
        let avg = totalCals/numberOfDays
        let roundedAvg = avg.roundTo(places: 0)
        let avgEx = totalExercise/numberOfDays
        let roundedEx = avgEx.roundTo(places: 0)
        let net = Int(roundedAvg - roundedEx)
        let goalCals = defaults.integer(forKey: "goal_calories")
        let left = goalCals - net
        let avgFoodString = NSMutableAttributedString(string: "Food: \(Int(roundedAvg))")
        avgFoodString.setColorForText(String(Int(roundedAvg)), with: #colorLiteral(red: 1, green: 0.4295217991, blue: 0, alpha: 1))
        averageLabel.attributedText = avgFoodString
        let avgExerciseString = NSMutableAttributedString(string: "Exercise: \(Int(roundedEx))")
        avgExerciseString.setColorForText(String(Int(roundedEx)), with: #colorLiteral(red: 1, green: 0.4295217991, blue: 0, alpha: 1))
        averageExerciseLabel.attributedText = avgExerciseString
        let netString = NSMutableAttributedString(string: "Net: \(net)")
        netString.setColorForText(String(net), with: #colorLiteral(red: 1, green: 0.4295217991, blue: 0, alpha: 1))
        netLabel.attributedText = netString
        let goalString = NSMutableAttributedString(string: "Goal: \(goalCals)")
        goalString.setColorForText(String(goalCals), with: #colorLiteral(red: 1, green: 0.4295217991, blue: 0, alpha: 1))
        goalLabel.attributedText = goalString
        let mainString = "Left: " + String(left)
        let stringToColor = String(left)
        let range = (mainString as NSString).range(of: stringToColor)
        let attribute = NSMutableAttributedString.init(string: mainString)
        let color = left >= 0 ? #colorLiteral(red: 0.01095554326, green: 0.4815165401, blue: 0.2025072575, alpha: 1) : #colorLiteral(red: 0.859279573, green: 0, blue: 0.1329188049, alpha: 1)
        leftLabel.text = mainString
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: range)
        leftLabel.attributedText = attribute
        arrayOfDates.reverse()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDate = arrayOfDates[indexPath.row]
        performSegue(withIdentifier: "SegueToHistory", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDates.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ByDateTableViewCell
        let d:Date = arrayOfDates[indexPath.row]
        let isToday = Calendar.current.isDateInToday(d)
        let isYesterday = Calendar.current.isDateInYesterday(d)
        if(isToday){
        cell.dateLabel.text = "Today"
        }else if(isYesterday){
        cell.dateLabel.text = "Yesterday"
        }
        else{
        cell.dateLabel.text = HelperMethods.convertDateToString(myDate: d, format: dateFormat)
        cell.backgroundColor = UIColor.white
        }
        let value = getDayLeft(date: d)
        let dateStat = dictOfDateStats[d]!
        if let _ = dictOfStats[d] {
        cell.leftLabel.attributedNegativePositive(mainString: String(dateStat.left), stringToColor:"\(value)")
        cell.calsLabel.text = String(dateStat.food)
        cell.exerciseLabel.text = String(dateStat.exercise)
        cell.netLabel.text = String(dateStat.net)
        cell.goalLabel.text = String(dateStat.goal)
        }else{
        cell.statsLabel.text = dictOfStats[d]
        }
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " Dates"
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = BLUE
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        label.text = " Dates"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        label.baselineAdjustment = .alignCenters
        label.textColor = .white
        returnedView.addSubview(label)
        return returnedView
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToHistory" {
            let historyVC = segue.destination as! HistoryViewController
            historyVC.currentDate = selectedDate
        }
    }
}

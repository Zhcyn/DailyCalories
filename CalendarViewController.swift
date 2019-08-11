import UIKit
import JTAppleCalendar
class CalendarViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    let white = UIColor(colorWithHexValue: 0xECEAED)
    let darkPurple = UIColor(colorWithHexValue: 0x3A284C)
    let dimPurple = UIColor(colorWithHexValue: 0x574865)
    var selectionNumber = 0
    var monthsAwayFromCurrent:Int = 0
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true
    }
    @IBAction func saveSelections(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dismiss(_ sender: Any) {
        Singleton.sharedInstance.pickedStartingDate = nil
        Singleton.sharedInstance.pickedEndingDate = nil
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func previousAction(_ sender: Any) {
        monthsAwayFromCurrent -= 1
        print(monthsAwayFromCurrent)
        calendarView.reloadData()
    }
    @IBAction func nextAction(_ sender: Any) {
        if(monthsAwayFromCurrent >= 0){
            return
        }
        monthsAwayFromCurrent += 1
        calendarView.reloadData()
    }
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        var startDate = Date().startOfMonth()
        startDate = Calendar.current.date(byAdding: .month, value: monthsAwayFromCurrent, to: startDate)!
        let endDate = Date()                                
        let month = startDate.convertDateToString(format: "MMMM yyyy")
        monthLabel.text = month
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        return  JTAppleCell()
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! CalendarCellView
        myCustomCell.dayLabel.text = cellState.text
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if(selectionNumber == 0){
            calendarView.deselectAllDates()
            Singleton.sharedInstance.pickedStartingDate = date
            selectionNumber = 1
        }else if(selectionNumber == 1){
            Singleton.sharedInstance.pickedEndingDate = date
            calendarView.selectDates(from: Singleton.sharedInstance.pickedStartingDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            selectionNumber = 0
        }
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CalendarCellView  else {
            return
        }
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = darkPurple
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = white
            } else {
                myCustomCell.dayLabel.textColor = dimPurple
            }
        }
    }
    func selectAllDatesInRange(start:Date,end:Date){
        var allDates:[Date] = []
        var currentDate = start
        while currentDate <= end{
            allDates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        print(allDates.count)
    }
    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = view as? CalendarCellView  else {
            return
        }
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  25
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
}

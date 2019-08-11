import UIKit
import RealmSwift
class EditEntriesViewController: UIViewController, UITextFieldDelegate{
    var entry = MyEntries()
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var proteinTextField:UITextField!
    @IBOutlet weak var carbsTextField:UITextField!
    @IBOutlet weak var fatTextField:UITextField!
    @IBOutlet weak var foodOrExerciseLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    var exercise = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if(entry.calories < 0){
            exercise = true
        }
        let entryType = exercise ? "Exercise" : "Food"
        saveButton.setTitle("Update \(entryType) ", for: .normal)
        foodOrExerciseLabel.text = "\(entryType) name"
        caloriesTextField.delegate = self
        caloriesTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        quantityTextField.delegate = self
        quantityTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        totalCaloriesLabel.layer.borderWidth = 1.0
        quantityTextField.text = String(entry.quantity)
        foodNameTextField.text = String(entry.name)
        let calsPerUnit = entry.calories/entry.quantity
        caloriesTextField.text = String(abs(calsPerUnit))
        totalCaloriesLabel.text = String(entry.calories)
        setInitialDate()
    }
    @objc func textFieldDidChange(_ textField:UITextField){
        if let calsDouble = Double(caloriesTextField.text!), let qDouble = Double(quantityTextField.text!){
            let total = calsDouble * qDouble
            totalCaloriesLabel.text = String(abs(total))
        }else{
            totalCaloriesLabel.text = "0"
        }
    }
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func dateBeginEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePickerView.date = entry.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EditEntriesViewController.datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
    }
    func setInitialDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateTextField.text = dateFormatter.string(from: entry.date)
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    func update(){
        let q = Double(quantityTextField.text!) ?? 1.0
        let c = Double(caloriesTextField.text!) ?? 0.0
        if(c * q == 0){
            return
        }
        let realm = try! Realm()
        try! realm.write {
            if(exercise){
            entry.calories = abs(c * q) * -1
            }else{
            entry.calories = abs(c * q)
            }
            let foodName = foodNameTextField.text!.lowercased()
            entry.name = foodName
            entry.quantity = Double(quantityTextField.text!)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.long
            dateFormatter.timeStyle = DateFormatter.Style.short
            entry.date = dateFormatter.date(from: dateTextField.text!)!
        }
        totalCaloriesLabel.text = String(entry.calories)
        NotificationCenter.default.post(name: Notification.Name("GoToFirstTab"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func updateAction(_ sender: Any) {
        update()
    }
}

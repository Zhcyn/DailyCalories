import UIKit
import RealmSwift
class EditWeightViewController: UIViewController {
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    var weightObject = MyWeights()
    override func viewDidLoad() {
        super.viewDidLoad()
        weightTextField.text = String(weightObject.weight)
        commentsTextView.text = weightObject.comments
        setInitialDate()
    }
    @IBAction func dateBeginEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePickerView.date = weightObject.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EditWeightViewController.datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
    }
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    func setInitialDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateTextField.text = dateFormatter.string(from: weightObject.date)
    }
    @IBAction func updateAction(_ sender: Any) {
       update()
        dismiss(animated: true, completion: nil)
    }
    func update(){
        let realm = try! Realm()
        try! realm.write {
            weightObject.weight = Double(weightTextField.text!)!
            weightObject.comments = commentsTextView.text!
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.long
            dateFormatter.timeStyle = DateFormatter.Style.short
            weightObject.date = dateFormatter.date(from: dateTextField.text!)!
        }
    }
}

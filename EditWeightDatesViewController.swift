import UIKit
protocol DatesPickedDelegate{
    func selectDates(from:Date?,to:Date?)
}
class EditWeightDatesViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    var currentTextField = UITextField()
    var currentDatePicked:Date?
    var delegate: DatesPickedDelegate?
    var fromDate:Date?
    var toDate:Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField(textField: fromTextField)
        configureTextField(textField: toTextField)
    }
    @IBAction func updateAction(_ sender: UIButton) {
        if(fromTextField.text == ""){
            fromDate = nil
        }else{
            fromDate = (fromTextField.inputView as! UIDatePicker).date
        }
        if(toTextField.text == ""){
            toDate = nil
        }else{
            toDate = (toTextField.inputView as! UIDatePicker).date
        }
        delegate?.selectDates(from: fromDate, to: toDate)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func resetAction(_ sender: UIButton) {
        fromDate = nil
        toDate = nil
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    func configureTextField(textField:UITextField){
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(EditWeightDatesViewController.datePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
    }
     @objc func datePickerValueChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        fromDate = sender.date
        currentTextField.text = dateFormatter.string(from: sender.date)
    }
}

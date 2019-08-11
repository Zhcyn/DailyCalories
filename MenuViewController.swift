import UIKit
import IAPController
import MessageUI
class MenuViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var weightUnitTextField: UITextField!
    @IBOutlet weak var goalCaloriesTextField: UITextField!
    @IBOutlet weak var versionLabel: UILabel!
    var pickOption = ["Kgs", "Lbs"]
    override func viewDidLoad() {
        super.viewDidLoad()
        if let v = versionNumber(){
        versionLabel.text = "Version \(v)"
        }
        self.title = "Settings"
        navigationController?.navigationBar.barTintColor = UIColor.red
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let pickerView = UIPickerView()
        pickerView.delegate = self
        weightUnitTextField.inputView = pickerView
        createBackButton()
        restoreGoalCalories()
        let weightUnit = restoreWeightType()
        if let weightUnit = weightUnit{
            if(weightUnit == "Kgs"){
                pickerView.selectRow(0, inComponent: 0, animated: false)
            }else{
                pickerView.selectRow(1, inComponent: 0, animated: false)
            }
        }
    }
    func sendEmail(){
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["jp@goappscanada.com"])
        composeVC.setSubject("DailyCalories Feedback")
        composeVC.setMessageBody("Hey JP! Here's my feedback", isHTML: false)
        self.present(composeVC, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    func openWebsite(){
    if let myWebsite = URL(string: "http://itunes.apple.com/app/id\(appId)") {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(myWebsite, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(myWebsite)
        }
        }
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func createBackButton(){
        let image = UIImage(named: "icons8-back_filled-2")
        let bckBtn = UIBarButtonItem(image:image!  , style: .plain, target: self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = bckBtn
    }
    @objc func backAction(){
        saveGoalCalories()
        saveWeightUnit()
      self.dismiss(animated: true, completion: nil)
    }
    func saveGoalCalories(){
        if let intCals = Int(goalCaloriesTextField.text!){
        let defaults = UserDefaults.standard
        defaults.set(intCals, forKey: "goal_calories")
        }
    }
    func restoreGoalCalories(){
        let defaults = UserDefaults.standard
        let goalCalories = defaults.integer(forKey: "goal_calories")
        goalCaloriesTextField.text = String(goalCalories)
    }
    func saveWeightUnit(){
            let stringType = weightUnitTextField.text!
            let defaults = UserDefaults.standard
            defaults.set(stringType, forKey: "weight_unit")
    }
    func restoreWeightType() -> String? {
        let defaults = UserDefaults.standard
        var weightUnit = defaults.string(forKey: "weight_unit")
        if(weightUnit == nil){
            weightUnit = "Lbs"
        }
        weightUnitTextField.text = weightUnit
        return weightUnit
    }
    func shareAction(){
        let textToShare = "Download DailyCalories. The most effortless way to track your calories."
        if let myWebsite = NSURL(string: "http://itunes.apple.com/app/id\(appId)") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    func rateAction(){
        openWebsite()
    }
    func openUrl(string:String){
        guard let url = URL(string: string) else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    func versionNumber() -> String?{
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return nil
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        weightUnitTextField.text = pickOption[row]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            switch indexPath.row {
            case 0:
                shareAction()
            case 1:
                print("rate")
                rateAction()
            default:
                print("invalid selection")
            }
        }
        if(indexPath.section == 0){
            switch indexPath.row {
            case 1:
                print("mail")
                sendEmail()
            default:
                print("invalid selection")
            }
        }
        if(indexPath.section == 2){
            if(indexPath.row == 0){
                self.openUrl(string: "https://icons8.com")
            }
        }
}
}

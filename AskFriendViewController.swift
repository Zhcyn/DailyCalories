import UIKit
class AskFriendViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var askFriendButton: UIButton!
    var selectedImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func imageAction(_ sender: UIButton) {
        chooseImageSourceAlert(sender: sender)
    }
    func share(textToShare:String,image:UIImage?){
        let appleId = "1249131148"
        if let myWebsite = URL(string: "http://itunes.apple.com/app/id\(appleId)") {
            let objectsToShare = [textToShare, myWebsite,image] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.assignToContact]
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width/2, y: self.view.frame.height, width: 1, height: 1)
            activityVC.popoverPresentationController?.permittedArrowDirections = [.init(rawValue: 0)]
            activityVC.completionWithItemsHandler = { activity, success, items, error in
                self.dismiss(animated: true, completion: nil)
            }
            self.present(activityVC, animated: true, completion: nil)
        }    }
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func askFriendAction(_ sender: UIButton) {
        guard let foodName = self.foodTextField.text else {
            self.basicAlert(title: "Error", message: "No food found", buttonTitle: "OK")
            return
        }
        if (selectedImage != nil || foodName.trim() != ""){
        self.share(textToShare: self.textView.text + "\n\nFood Name:\(foodName)\n\n", image: selectedImage)
        }else{
        self.basicAlert(title: "", message: "Please choose an image of enter a food name.", buttonTitle: "OK")
        }
    }
    func chooseImageSourceAlert(sender:UIView){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed the cancel button");
        }
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (action:UIAlertAction) in
            self.openCamera()
        }
        let actionGallery = UIAlertAction(title: "Gallery", style: .default) { (action:UIAlertAction) in
            self.openLibrary()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionCamera)
        alert.addAction(actionGallery)
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = sender.frame
            popoverPresentationController.permittedArrowDirections = .down
        }
        self.present(alert, animated: true, completion: nil)
    }
    func openLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let imgInfoString = UIDevice.current.userInterfaceIdiom == .pad ? UIImagePickerController.InfoKey.originalImage : UIImagePickerController.InfoKey.editedImage
        if let image = info[imgInfoString] as? UIImage {
            selectedImage = image
            imageButton.setImage(image, for: .normal)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

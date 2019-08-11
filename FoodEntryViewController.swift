import UIKit
import RealmSwift
import EFCountingLabel
import Popover
import PBTutorialManager
class FoodEntryViewController: UIViewController,UITextFieldDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var caloriesLabelBg: UIView!
    @IBOutlet weak var favsBackground: UIView!
    @IBOutlet weak var askFriendBtn: UIButton!
    @IBOutlet weak var settingsBackground: UIView!
    @IBOutlet weak var keyboardFavsBackgroundView: UIView!
    @IBOutlet weak var caloriesToEnterLabel: UILabel!
    @IBOutlet weak var calsListTab: UIView!
    @IBOutlet weak var keyboardView: UIView!
    @IBOutlet weak var infoBackgroundView: UIView!
    @IBOutlet weak var caloriesLabel: EFCountingLabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var statsLabel: UIView!
    @IBOutlet weak var unsureTitleLabel: UILabel!
    @IBOutlet weak var fav1Button: UIButton!
    @IBOutlet weak var fav2Button: UIButton!
    @IBOutlet weak var fav3Button: UIButton!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var askAFriendButton: UIButton!
    @IBOutlet weak var searchTheWebButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var favsCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    var removingValue:Bool = false
    @IBOutlet weak var exerciseLabel: EFCountingLabel!
    @IBOutlet weak var netCaloriesLabel: EFCountingLabel!
    @IBOutlet weak var searchTab: UIView!
    @IBOutlet weak var goalCaloriesLabel: UILabel!
    @IBOutlet weak var leftCaloriesLabel: EFCountingLabel!
    @IBOutlet weak var exerciseButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var foodPlusButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var favsLabel: UILabel!
    @IBOutlet weak var keyboardBgView: UIView!
    let defaults=UserDefaults()
    var goal:Int = 2000
    var totalCalories = 0
    var quantityOfItems:Double = 1.0
    @IBOutlet weak var unsureView: UIView!
    var favFoodsArray: Results<MyFoods>!
    var currentNumber: Int = 0 {
        didSet {
            caloriesToEnterLabel.text = String(currentNumber)
            if(currentNumber > 0){
                say("Tap the buttons above to add/remove \(self.currentNumber) calories")
                commentsLabel.alpha = 1.0
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Singleton.sharedInstance.proUser = defaults.bool(forKey: "proUser")
        print(Singleton.sharedInstance.proUser)
        caloriesLabel.format = "%d"
        exerciseLabel.format = "%d"
        netCaloriesLabel.format = "%d"
        leftCaloriesLabel.format = "%d"
        leftCaloriesLabel.setPositiveNegativeColor()
        netCaloriesLabel.text = String(totalCalories)
        self.commentsLabel.text = ""
    }
    @IBAction func closeAction(_ sender: UIButton) {
        self.unsureView.alpha = 0.0
    }
    @IBAction func menuAction(_ sender: UIButton) {
        HelperMethods().presentMenu(vc: self, sender: sender)
    }
    @IBAction func searchWebAction(_ sender: UIButton) {
        self.unsureView.alpha = 0.0
        self.tabBarController?.selectedIndex = 3
    }
    @IBAction func askFriendAction(_ sender: UIButton) {
        self.unsureView.alpha = 0.0
    }
    @IBAction func guessAction(_ sender: UIButton) {
        self.unsureView.alpha = 0.0
    }
    override func viewWillLayoutSubviews() {
        caloriesToEnterLabel.layer.cornerRadius = 0.12 * caloriesToEnterLabel.bounds.size.width
        caloriesLabelBg.layer.cornerRadius = 0.20 * caloriesLabelBg.bounds.size.width
        caloriesToEnterLabel.layer.borderWidth = 1.0
        leftCaloriesLabel.layer.masksToBounds = true
        leftCaloriesLabel.layer.cornerRadius = 0.2 * leftCaloriesLabel.bounds.size.width
        caloriesToEnterLabel.layer.borderWidth = 1.0
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    @IBAction func questionMarkAction(_ sender: UIButton) {
        self.unsureView.alpha = 1.0
    }
    func addTutorial(){
        let targetKeyboard = TutorialTarget(view: keyboardBgView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.top)
            .shape(.rect)
            .duration(1.0)
            .message("Start by entering the number of calories for the food/exercise you want to add")
            .breakPoint(true)
        let targetStats = TutorialTarget(view: statsLabel)
        .withArrow(true)
        .heightArrow(50)
        .widthArrow(25)
        .position(.bottom)
        .shape(.rect)
        .duration(1.0)
        .message("Here you see your stats for the day")
        .breakPoint(true)
        let targetCurrent = TutorialTarget(view: caloriesToEnterLabel)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottom)
            .shape(.rect)
            .duration(1.0)
            .message("The number of calories entered will appear here")
            .breakPoint(true)
        let targetFood = TutorialTarget(view: foodButton)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottom)
            .shape(.rect)
            .duration(1.0)
            .message("Tap here to quickly add that number as calories consumed")
            .breakPoint(true)
        let targetFoodPlus = TutorialTarget(view: foodPlusButton)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottom)
            .shape(.rect)
            .duration(1.0)
            .message("Tap here to add more info to your entry such as time,quantity and name.")
            .breakPoint(true)
        let targetExercise = TutorialTarget(view: exerciseButton)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottom)
            .shape(.rect)
            .duration(1.0)
            .message("Tap here to quickly add calories burned")
            .breakPoint(true)
        let targetFavs = TutorialTarget(view: favsBackground)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.top)
            .shape(.rect)
            .duration(1.0)
            .message("Your favourites will appear here.")
            .breakPoint(true)
        let targetCalsList = TutorialTarget(view: calsListTab)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(80)
            .position(.top)
            .shape(.rect)
            .duration(1.0)
            .message("Create your favourites on the Calories List tab")
            .breakPoint(true)
        let targetSearch = TutorialTarget(view: searchTab)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(80)
            .position(.top)
            .shape(.rect)
            .duration(1.0)
            .message("If you don't know the calories for a food or exercise look it up on the Search tab")
            .breakPoint(true)
        let targetFriend = TutorialTarget(view: askFriendBtn)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(80)
            .position(.bottomRight)
            .shape(.rect)
            .duration(1.0)
            .message("Tap here to get help from a friend to determine the number of calories")
            .breakPoint(true)
        let targetSettings = TutorialTarget(view: settingsBackground)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottomRight)
            .shape(.rect)
            .duration(1.0)
            .message("Go to settings to edit your calories goal")
            .breakPoint(true)
        let targetInfo = TutorialTarget(view: infoBackgroundView)
            .withArrow(true)
            .heightArrow(50)
            .widthArrow(25)
            .position(.bottomLeft)
            .shape(.rect)
            .duration(1.0)
            .message("Tap here to see this tutorial again")
            .breakPoint(true)
        let tutorialManager = TutorialManager(parent: view)
        tutorialManager.addTarget(targetKeyboard)
        tutorialManager.addTarget(targetCurrent)
        tutorialManager.addTarget(targetFood)
        tutorialManager.addTarget(targetExercise)
        tutorialManager.addTarget(targetFoodPlus)
        tutorialManager.addTarget(targetStats)
        tutorialManager.addTarget(targetCalsList)
        tutorialManager.addTarget(targetFavs)
        tutorialManager.addTarget(targetSearch)
        tutorialManager.addTarget(targetFriend)
        tutorialManager.addTarget(targetSettings)
        tutorialManager.addTarget(targetInfo)
        tutorialManager.fireTargets()
    }
    @IBAction func infoAction(_ sender: UIButton) {
        addTutorial()
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
    func retrieveFavs(){
        let realm = try! Realm()
        let predicate = NSPredicate(format: "favourite = true")
        favFoodsArray =  realm.objects(MyFoods.self).filter(predicate).sorted(byKeyPath: "name", ascending: true)
        collectionView.reloadData()
    }
    func getPopoverText(theView:UIView) -> String{
        switch theView {
        case infoButton:
            return "Tap the tip to go to the next tip. Tap anywhere else to dismiss."
        case exerciseButton:
            return "Add calories burned here"
        case foodButton:
            return "Add calories consumed here"
        case foodPlusButton:
            return "Add calories consumed and edit quantity and/or food name"
        case favsLabel:
            return "Set your favourites on the Calories List tab."
        default:
            return "Tap the info button for a tutorial"
        }
    }
    func showPopover(theView:UIView,options:[PopoverOption],popoverFrame:CGRect){
        let aView = UIView(frame: popoverFrame)
        let aLabel = UILabel(frame: popoverFrame)
        aLabel.text = getPopoverText(theView: theView)
        aLabel.font = aLabel.font.withSize(12)
        aLabel.numberOfLines = 0
        aLabel.textAlignment = .center
        aView.addSubview(aLabel)
        let popover = Popover(options: options, showHandler: nil, dismissHandler: nil)
        popover.show(aView, fromView: theView)
    }
    @IBAction func addDigit(_ sender: UIButton) {
        let newNumber = currentNumber * 10 + sender.tag
        currentNumber = newNumber < 100000 ? newNumber : currentNumber
    }
    @IBAction func fav1Action(_ sender: UIButton) {
      let newNumber = sender.tag
      currentNumber = newNumber < 100000 ? newNumber : currentNumber
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commentsLabel.alpha = 0.0
        currentNumber = 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let shownTut = defaults.bool(forKey: "shownTut")
        if(!shownTut){
            addTutorial()
            defaults.set(true, forKey: "shownTut")
        }
        retrieveFavs()
        if let pickedCalories = Singleton.sharedInstance.pickedCalories{
        self.currentNumber = Int(pickedCalories)
        }
        selectedFoods()
        getToday()
    }
    func say(_ comment:String){
    commentsLabel.alpha = 1.0
    commentsLabel.text = comment
    UIView.animate(withDuration: 3, animations: {
        self.commentsLabel.alpha = 0.0
        }, completion: nil)
    }
    func convertToString(n:Int) -> String{
        if(n >= 0){
            return "+" + String(n)
        }else{
            return String(n)
        }
    }
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        getToday()
    }
    func moreDetailsAlert(){
        let titleText = self.currentNumber > 0 ? "Add Food" : "Add Exercise"
        let addString = self.currentNumber > 0 ? "consume" : "burn"
        let alert = UIAlertController(title: titleText,
                                      message: "You will \(addString) \(self.currentNumber.magnitude) calories for each unit",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Add", style: .default, handler: { (action) -> Void in
            let quantityTextField = alert.textFields![0]
            let foodTextField = alert.textFields![1]
            self.quantityOfItems = Double(quantityTextField.text!) ?? 1.0
            self.removingValue = self.currentNumber < 0
            self.createNewEntry(cals: self.currentNumber, quantity: self.quantityOfItems, name: foodTextField.text!)
            self.currentNumber = 0
                                })
        let addAndSaveAction = UIAlertAction(title: "Add and save food", style: .default, handler: { (action) -> Void in
            let quantityTextField = alert.textFields![0]
            let foodTextField = alert.textFields![1]
            let quantity = Double(quantityTextField.text!) ?? 1.0
            self.removingValue = self.currentNumber < 0
            self.createNewEntry(cals: self.currentNumber, quantity: quantity, name: foodTextField.text!)
            self.saveFood(name: foodTextField.text!, calories: Double(self.currentNumber))
            self.currentNumber = 0
        })
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .decimalPad
            textField.autocorrectionType = .default
            textField.placeholder = "Quantity"
            textField.text = "1"
        }
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "Food description"
            textField.text = Singleton.sharedInstance.pickedFood
            textField.becomeFirstResponder()
        }
        alert.addAction(okAction)
        if(Singleton.sharedInstance.pickedCalories == nil){
        alert.addAction(addAndSaveAction)
        }
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func saveFood(name: String, calories:Double){
        if(name.trim() == ""){
        self.basicAlert(title: "Error saving food to database", message: "Can't save food with empty name", buttonTitle: "OK")
            return
        }
        let nFoods = RealmHelper.getNumberOfFoods()
        if(nFoods >= maxFreeFoods && Singleton.sharedInstance.proUser == false){
            self.basicAlert(title: "You must buy the pro version to create more than \(maxFreeFoods) foods", message: "", buttonTitle: "OK")
            return
        }
        let realm = try! Realm()
        let myFood = MyFoods()
        myFood.calories = calories
        myFood.name = name.lowercased().trim()
        let foodThatExists = realm.objects(MyFoods.self).filter("name == '\(myFood.name)'").first
        if let food = foodThatExists{
            updateValueAlert(food: food, name: name, cals: calories)
            return
        }
        try! realm.write {
            realm.add(myFood)
            self.basicAlert(title: "Saved", message: "New food added to your Calories List", buttonTitle: "OK")
        }
    }
    func updateValueAlert(food:MyFoods,name:String,cals:Double){
        let alertController = UIAlertController(title: "That food already exists in the database", message: "Do you want to update it with the new value?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed the cancel button");
        }
        let actionAdd = UIAlertAction(title: "YES", style: .default) { (action:UIAlertAction) in
            let realm = try! Realm()
            try! realm.write {
                let foodName = name.lowercased().trim()
                food.name = foodName
                food.calories = cals
            }
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionAdd)
        self.present(alertController, animated: true, completion:nil)
    }
    func getToday(){
        let realm = try! Realm()
        let start = Calendar.current.startOfDay(for: Date())
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
        caloriesLabel.add(Int(cal) - Int(caloriesLabel.text!)!)
        exerciseLabel.add(Int(ex) - Int(exerciseLabel.text!)!)
        goal = restoreGoalCalories()
        let net:Int = Int(cal) - Int(ex)
        caloriesLabel.text = String(Int(cal))
        netCaloriesLabel.add(Int(net) - Int(netCaloriesLabel.text!)!)
        netCaloriesLabel.text = String(net)
        exerciseLabel.text = String(Int(ex))
        goalCaloriesLabel.text = String(goal)
        leftCaloriesLabel.add(Int(goal - net) - Int(leftCaloriesLabel.text!)!)
        leftCaloriesLabel.text = String(goal - net)
    }
    func addCalories(){
        let caloriesAdded = Double(currentNumber) * quantityOfItems
        let calsInt = Int(caloriesAdded.magnitude)
        if(removingValue){
            exerciseLabel.add(calsInt)
            leftCaloriesLabel.add(calsInt)
            netCaloriesLabel.subtract(calsInt)
        }else{
            caloriesLabel.add(calsInt)
            netCaloriesLabel.add(calsInt)
            leftCaloriesLabel.subtract(calsInt)
        }
        removingValue = false
        quantityOfItems = 1.0
    }
    func selectedFoods(){
        if let _ = Singleton.sharedInstance.pickedCalories, let _ = Singleton.sharedInstance.pickedFood {
        moreDetailsAlert()
        }
        Singleton.sharedInstance.pickedFood = nil
        Singleton.sharedInstance.pickedCalories = nil
    }
    @IBAction func addFav(_ sender: UIButton) {
        let newNumber = currentNumber + sender.tag
        currentNumber = newNumber < 100000 ? newNumber : currentNumber
    }
    @IBAction func removeDigit(_ sender: UIButton) {
        currentNumber = currentNumber/10
        if(currentNumber == 0){
        say("")
        }
    }
    @IBAction func clearAction(_ sender: UIButton) {
        currentNumber = 0
        say("")
    }
    @IBAction func addAction(_ sender: UIButton) {
        addFood(tag: sender.tag)
     }
    func addFood(tag:Int){
        if tag == 1{
            if(currentNumber == 0){
                say("Please choose a number higher than 0")
                return
            }
            createNewEntry(cals: currentNumber, quantity: 1.0, name: "")
            currentNumber = 0
        }else if (tag == -1){
            if(currentNumber == 0){
                say("Please choose a number higher than 0")
                return
            }
            removingValue = true
            createNewEntry(cals: -currentNumber, quantity: 1.0, name: "")
            currentNumber = 0
        }else if (tag == 2){
            goToDetailedEntryVC()
        }
    }
    func goToDetailedEntryVC(){
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailed") as? DetailedEntryViewController
        {
            let newEntry = MyEntries()
            newEntry.calories = Double(currentNumber)
            newEntry.quantity = 1.0
            newEntry.date = Date()
            newEntry.name = ""
            vc.entry = newEntry
            present(vc, animated: true, completion: nil)
        }
    }
    func createNewEntry(cals:Int,quantity:Double,name:String){
        let calsDouble = Double(cals)
        let calsForEntry = calsDouble*quantity
        let realm = try! Realm()
        let myEntry = MyEntries()
        myEntry.calories = calsForEntry
        myEntry.name = name
        myEntry.date = Date()
        myEntry.quantity = quantity
            try! realm.write {
            realm.add(myEntry)
            say(enteredCalsString(cals: calsForEntry))
            addCalories()
        }
    }
    func enteredCalsString(cals:Double) -> String{
        return cals >= 0 ? "You consumed \(cals) calories" : "You burned \(-cals) calories"
    }
    func restoreGoalCalories() -> Int{
        let defaults = UserDefaults.standard
        var goalCalories = defaults.integer(forKey: "goal_calories")
        if(goalCalories == 0){
            defaults.set(2000, forKey: "goal_calories")
            goalCalories = 2000
        }
        goalCaloriesLabel.text = String(goalCalories)
        return goalCalories
    }
    func addRoundedCorners(view:UIView){
        view.layer.cornerRadius = 2.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.masksToBounds = true
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let food = favFoodsArray[indexPath.row]
        currentNumber = Int(food.calories)
        removingValue = currentNumber < 0
      self.createNewEntry(cals: Int(food.calories), quantity: 1, name: food.name)
        currentNumber = 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FavsCollectionViewCell
        let food = favFoodsArray[indexPath.row]
        cell.foodNameLabel.text = food.name
        cell.caloriesLabel.text = String(Int(food.calories))
        cell.backgroundColor = food.calories >= 0 ? #colorLiteral(red: 0.04695361108, green: 0.5299931765, blue: 0.6772642732, alpha: 1)  : #colorLiteral(red: 0.9982196689, green: 0.3983421922, blue: 0, alpha: 1)
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if let favFoodsArray = favFoodsArray{
        return favFoodsArray.count
        }
        return 0
    }
    }

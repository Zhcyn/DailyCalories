import UIKit
import RealmSwift
import Popover
import StoreKit
import PBTutorialManager
import SCLAlertView
import IAPController
class FoodListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var PlusBg: UIView!
    var loadedView = true
    var shownTutorial = false
    var myFoodsArray: Results<MyFoods>!
    var filteredArray: Results<MyFoods>!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        retrieveFoods()
        tableView.reloadData()
    }
    func presentMenu(sender: UIButton){
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Menu")
        self.present(popController, animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    @IBAction func starAction(_ sender: UIButton) {
        if(searchBar.text == ""){
            let food = myFoodsArray[sender.tag]
            let fav:Bool = food.favourite ? false : true
            update(name: food.name, favourite: fav)
        }else{
            let food = filteredArray[sender.tag]
            let fav:Bool = food.favourite ? false : true
            update(name: food.name, favourite: fav)
        }
        tableView.reloadData()
    }
    @IBAction func menuAction(_ sender: UIButton) {
        HelperMethods().presentMenu(vc: self, sender: sender)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadedView = false
        retrieveFoods()
        tableView.reloadData()
    }
    func editFood(){
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        retrieveFiltered()
        tableView.reloadData()
    }
    func presentEditFoodAlertController(food:MyFoods){
        let alertController = UIAlertController(title: food.name, message: "Enter number of calories", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed the cancel button");
        }
        let actionAdd = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            let textCalories = alertController.textFields![0] as UITextField
            guard let cals = Double(textCalories.text!) else{
                self.basicAlert(title: "Error", message: "Invalid format for calories", buttonTitle: "OK")
                self.presentEditFoodAlertController(food: food)
                return
            }
            let realm = try! Realm()
            try! realm.write {
                let foodName = food.name.lowercased().trim()
                food.name = foodName
                food.calories = cals
            }
            self.retrieveFoods()
            self.tableView.reloadData()
        }
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Calories"
            textField.text = String(Int(food.calories))
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionAdd)
        self.present(alertController, animated: true, completion:nil)
    }
    func presentAlertFood(){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        let value = HelperMethods.getUIntValueFromHex(hex: "3D85A9")!
        let nameText = alertView.addTextField("Name")
        let calsText = alertView.addTextField("Calories")
        calsText.keyboardType = .decimalPad
        alertView.addButton("Food") {
        let foodName = nameText.text
        let cals = calsText.text
            if let foodName = foodName, let cals = cals, let calsDouble = Double(cals){
        self.saveFood(name: foodName, calories: calsDouble)
        self.retrieveFoods()
        self.tableView.reloadData()
            }
        }
        alertView.addButton("Exercise") {
            let foodName = nameText.text
            let cals = calsText.text
            if let foodName = foodName, let cals = cals, let calsDouble = Double(cals){
            self.saveFood(name: foodName, calories: -calsDouble)
            self.retrieveFoods()
            self.tableView.reloadData()
            }
        }
        alertView.addButton("Cancel", backgroundColor: ORANGE,action: {})
        alertView.showSuccess("New item", subTitle: "Create a new food or exercise", closeButtonTitle: "Cancel", colorStyle: value)
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
            self.retrieveFoods()
            self.tableView.reloadData()
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionAdd)
        self.present(alertController, animated: true, completion:nil)
    }
    func update(name:String,favourite:Bool){
        let realm = try! Realm()
        let food = realm.objects(MyFoods.self).filter("name = %@", name)
        if let food = food.first {
            try! realm.write {
                food.favourite = favourite
            }
        }
    }
    @IBAction func newFoodAction(_ sender: Any) {
        presentAlertFood()
        }
    func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
        }
    }
    func showTutorial(){
            let addBtn = TutorialTarget(view: PlusBg)
                .withArrow(true)
                .heightArrow(50)
                .widthArrow(25)
                .position(.bottomLeft)
                .shape(.rect)
                .duration(1.0)
                .message("Tap here to create your first food")
                .breakPoint(true)
            let tutorialManager = TutorialManager(parent: view)
            tutorialManager.addTarget(addBtn)
            tutorialManager.fireTargets()
    }
    func saveFood(name: String, calories:Double){
        let nFoods = getNumberOfFoods()
        let value = HelperMethods.getUIntValueFromHex(hex: "3D85A9")!
        if(nFoods >= maxFreeFoods && Singleton.sharedInstance.proUser == false){
            var productPrice:String = ""
            if let product = IAPController.sharedInstance.products?.first {
             productPrice = product.priceFormatted ?? ""
            }
            let alertView = SCLAlertView()
            alertView.addButton("Buy \(productPrice)") {
                if let product = IAPController.sharedInstance.products?.first {
                    product.buy()
                }
            }
            alertView.showSuccess("Unlimited Foods!!", subTitle: "You must buy the pro version to create more than \(maxFreeFoods) foods", closeButtonTitle: "Cancel", colorStyle: value)
            return
        }
        if nFoods == 25 || nFoods == 50 || nFoods == 250 || nFoods == 500 {
         requestReview()
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
        }
        }
    func retrieveFoods(){
        let realm = try! Realm()
        myFoodsArray =  realm.objects(MyFoods.self).sorted(byKeyPath: "name", ascending: true)
        print(myFoodsArray)
        if(myFoodsArray.count == 0){
            if(!loadedView && !shownTutorial){
            showTutorial()
            shownTutorial = true
            }
        }
    }
    func retrieveFiltered(){
        let realm = try! Realm()
        let predicate = NSPredicate(format: "name contains[c] %@", searchBar.text!)
        filteredArray =  realm.objects(MyFoods.self).filter(predicate).sorted(byKeyPath: "name", ascending: true)
        print(myFoodsArray)
    }
    func getNumberOfFoods() -> Int {
        let realm = try! Realm()
        let foodsArray =  realm.objects(MyFoods.self).sorted(byKeyPath: "name", ascending: true)
        return foodsArray.count
    }
    func delete(index:Int){
        let myFood = myFoodsArray[index]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(myFood)
            self.tableView.reloadData()
        }
    }
    func deleteFromFiltered(index:Int){
        let myFood = filteredArray[index]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(myFood)
            self.tableView.reloadData()
        }
    }
    func getStarImage(food:MyFoods) -> UIImage{
        if(food.calories > 0){
            if(food.favourite){
                return #imageLiteral(resourceName: "icons8-star_filled-1")
            }else{
                return #imageLiteral(resourceName: "icons8-star-1")
            }
        }else{
            if(food.favourite){
                return #imageLiteral(resourceName: "icons8-star_filled-3")
            }else{
                return #imageLiteral(resourceName: "icons8-star-3")
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchBar.text != ""){
            return self.filteredArray.count
        }
        return self.myFoodsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FoodTableViewCell
        if(searchBar.text == ""){
            let food = myFoodsArray[indexPath.row]
            cell.starButton.tag = indexPath.row
            let img = getStarImage(food: food)
            cell.starButton.setImage(img, for: .normal)
            cell.caloriesLabel.text = "\(Int(food.calories)) calories"
            cell.nameLabel.text = myFoodsArray[indexPath.row].name
        }
        else if(searchBar.text != ""){
            let food = filteredArray[indexPath.row]
            let img = getStarImage(food: food)
            cell.starButton.setImage(img, for: .normal)
            cell.caloriesLabel.text = "\(Int(food.calories)) calories"
            cell.nameLabel.text = filteredArray[indexPath.row].name
            cell.starButton.tag = indexPath.row
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(searchBar.text == ""){
            let foodSelected = myFoodsArray[indexPath.row]
            goToDetailedEntryVC(food: foodSelected)
        }else{
            let foodSelected = filteredArray[indexPath.row]
            goToDetailedEntryVC(food: foodSelected)
        }
    }
    func goToDetailedEntryVC(food:MyFoods){
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailed") as? DetailedEntryViewController
        {
            let newEntry = MyEntries()
            newEntry.calories = abs(food.calories)
            newEntry.quantity = 1.0
            newEntry.date = Date()
            newEntry.name = food.name
            vc.entry = newEntry
            present(vc, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
        if(searchBar.text == ""){
        delete(index: indexPath.row)
        }else{
        deleteFromFiltered(index: indexPath.row)
        }
        retrieveFoods()
        tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action:UITableViewRowAction, indexPath:IndexPath) in
                if(self.searchBar.text == ""){
                    self.delete(index: indexPath.row)
                }else{
                    self.deleteFromFiltered(index: indexPath.row)
                }
                self.retrieveFoods()
                tableView.reloadData()
            }
        delete.backgroundColor = .red
        let edit = UITableViewRowAction(style: .default, title: "Edit") { (action:UITableViewRowAction, indexPath:IndexPath) in
            if(self.searchBar.text == ""){
                let food = self.myFoodsArray[indexPath.row]
                self.presentEditFoodAlertController(food: food)
            }else{
                let food = self.filteredArray[indexPath.row]
                self.presentEditFoodAlertController(food: food)
            }
        }
        edit.backgroundColor = .blue
        return [delete, edit]
    }
}

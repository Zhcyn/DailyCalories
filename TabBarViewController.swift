import UIKit
class TabBarViewController: UITabBarController {
    let userDefaults = UserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToFirstTab(notification:)), name: Notification.Name("GoToFirstTab"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.purchased(notification:)), name: Notification.Name("IAPControllerPurchasedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetched(notification:)), name: Notification.Name("IAPControllerFetchedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.failed(notification:)), name: Notification.Name("IAPControllerFailedNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.restored(notification:)), name: Notification.Name("IAPControllerRestoredNotification"), object: nil)
    }
    @objc func goToFirstTab(notification: Notification){
        self.selectedIndex = 0
    }
    @objc func purchased(notification: Notification){
        print("purchased")
        Singleton.sharedInstance.proUser = true
        userDefaults.set(true, forKey: "proUser")
    }
    @objc func fetched(notification: Notification){
        print("fetched")
    }
    @objc func failed(notification: Notification){
        print("failed")
        if let vc = getCurrent(){
        if(vc is MenuViewController){
        vc.basicAlert(title: "Purchase failed", message: "", buttonTitle: "OK")
        }
        }
    }
    @objc func restored(notification: Notification){
        print("restored")
        Singleton.sharedInstance.proUser = true
        userDefaults.set(true, forKey: "proUser")
        if let vc = getCurrent(){
        vc.basicAlert(title: "Restored", message: "", buttonTitle: "OK")
        }
    }
    func getCurrent() -> UIViewController?{
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
        return nil
    }
}

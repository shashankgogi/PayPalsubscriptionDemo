//
//  AppDelegate.swift
//  iOS_SubscriptionPlug
//
//  Created by macbook pro on 20/11/18.
//  Copyright © 2018 Omni-Bridge. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Init braintree with return URL Schema
        BTAppSwitch.setReturnURLScheme("com.ob.iOS-PayPalSubscriptionPlug.Payments")
        
        //Initialize Scrollable Segment Controller
        let segmentedControlAppearance = ScrollableSegmentedControl.appearance()
        segmentedControlAppearance.segmentContentColor = UIColor.white
        segmentedControlAppearance.selectedSegmentContentColor = UIColor.yellow
        segmentedControlAppearance.backgroundColor = UIColor.black
        
        if UserDefaults.standard.value(forKey: "StartURLFromServer") == nil{
            self.callToSetConfigeUrl()
        }else{
            self.loadInitialViewController()
        }
        return true
    }
    
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.ob.iOS-PayPalSubscriptionPlug.Payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    // MARK:- Confige URL
    
    /// Uset to set confige url from server
    private func callToSetConfigeUrl(){
        if General.isConnectedToNetwork(){
            if GetApiConfig.execute(){
                self.loadInitialViewController()
            }else{
                showErrorAlert(message: "Somwthing went wrong. Please contact to your Admin!")
            }
        }else{
            self.showErrorAlert(message: "No internet available. Please check your connection.")
        }
    }
    
    /// Used to load initial view controller
    private func loadInitialViewController(){
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController : UINavigationController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
    }
    
    /// Used to show Error alert
    func showErrorAlert(message : String){
        let alertVC = UIAlertController(title: "Oops" , message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel) { (alert) in
            exit(0)
        }
        alertVC.addAction(okAction)
        DispatchQueue.main.async {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    
}


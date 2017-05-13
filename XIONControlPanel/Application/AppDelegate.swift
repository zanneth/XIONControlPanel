//
//  AppDelegate.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var mainViewController: MainViewController = MainViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        application.isStatusBarHidden = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.mainViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        self.mainViewController.viewDidAppear(false)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        self.mainViewController.viewDidDisappear(false)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        var mask: UIInterfaceOrientationMask = .portrait
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            mask = UIInterfaceOrientationMask.portrait
        } else {
            mask = UIInterfaceOrientationMask.all
        }
        
        return mask
    }
}

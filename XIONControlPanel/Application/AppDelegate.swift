//
//  AppDelegate.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var mainViewController: MainViewController = MainViewController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        application.statusBarHidden = true
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = self.mainViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication)
    {
        self.mainViewController.viewDidAppear(false)
    }
    
    func applicationDidEnterBackground(application: UIApplication)
    {
        self.mainViewController.viewDidDisappear(false)
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Landscape
    }
}

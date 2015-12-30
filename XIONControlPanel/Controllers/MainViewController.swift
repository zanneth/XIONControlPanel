//
//  MainViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private var _backgroundController: BackgroundViewController = BackgroundViewController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.addChildViewController(_backgroundController)
        self.view.addSubview(_backgroundController.view)
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        _backgroundController.view.frame = bounds
    }
}

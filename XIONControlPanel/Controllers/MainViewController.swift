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
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.addChildViewController(_backgroundController)
        self.view.addSubview(_backgroundController.view)
        
        let doubleTapGR = UITapGestureRecognizer(target: self, action: Selector("_handleDoubleFingerTap:"))
        doubleTapGR.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(doubleTapGR)
        
        let singleTapGR = UITapGestureRecognizer(target: self, action: Selector("_handleSingleFingerTap:"))
        singleTapGR.numberOfTouchesRequired = 1
        singleTapGR.requireGestureRecognizerToFail(doubleTapGR)
        self.view.addGestureRecognizer(singleTapGR)
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
    
    // MARK: Internal
    
    internal func _handleSingleFingerTap(gestureRecognizer: UITapGestureRecognizer)
    {
        let randomPercentage = Float(arc4random()) / Float(UInt32.max)
        _backgroundController.setPercentActivated(randomPercentage, animated: true)
    }
    
    internal func _handleDoubleFingerTap(gestureRecognizer: UITapGestureRecognizer)
    {
        _backgroundController.setPercentActivated(0.0, animated: true)
    }
}

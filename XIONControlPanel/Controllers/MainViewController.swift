//
//  MainViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private var _visualizationController:   VisualizationViewController = VisualizationViewController()
    private var _machinesController:        ArcadeMachinesViewController = ArcadeMachinesViewController()
    private var _headerView:                HeaderView = HeaderView()
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.addChildViewController(_visualizationController)
        self.view.addSubview(_visualizationController.view)
        
        self.addChildViewController(_machinesController)
        self.view.addSubview(_machinesController.view)
        
        self.view.addSubview(_headerView)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        let headerBounds = CGRect(
            x: 0.0,
            y: 0.0,
            width: bounds.size.width,
            height: rint(bounds.size.height / 10.0)
        )
        let bodyBounds = CGRect(
            x: 0.0,
            y: CGRectGetMaxY(headerBounds),
            width: bounds.size.width,
            height: bounds.size.height - headerBounds.size.height
        )
        
        _headerView.frame = headerBounds
        
        let visualizationFrame = CGRect(
            x: bodyBounds.origin.x,
            y: bodyBounds.origin.y,
            width: rint((5.0 / 8.0) * bodyBounds.size.width),
            height: bodyBounds.size.height
        )
        _visualizationController.view.frame = visualizationFrame
        
        let machinesControllerFrame = CGRect(
            x: CGRectGetMaxX(visualizationFrame),
            y: bodyBounds.origin.y,
            width: bodyBounds.size.width - visualizationFrame.size.width,
            height: bodyBounds.size.height
        )
        _machinesController.view.frame = machinesControllerFrame
    }
    
    override func viewDidAppear(animated: Bool)
    {
        _headerView.xionLogoView.beginAnimating()
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        _headerView.xionLogoView.stopAnimating()
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}

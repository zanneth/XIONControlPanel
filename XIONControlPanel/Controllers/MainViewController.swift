//
//  MainViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SwitchesViewControllerDelegate {
    private var _visualizationController:   VisualizationViewController = VisualizationViewController()
    private var _switchesController:        SwitchesViewController = SwitchesViewController()
    private var _headerView:                HeaderView = HeaderView()
    
    // MARK: Overrides
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.addChildViewController(_visualizationController)
        self.view.addSubview(_visualizationController.view)
        
        _switchesController.delegate = self
        self.addChildViewController(_switchesController)
        self.view.addSubview(_switchesController.view)
        
        self.view.addSubview(_headerView)
        
        // DEBUG
        for _ in 0 ..< 10 {
            let device = WemoDevice()
            device.name = "beatmania IIDX"
            self.devices.append(device)
        }
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
            width: rint(0.6 * bodyBounds.size.width),
            height: bodyBounds.size.height
        )
        _visualizationController.view.frame = visualizationFrame
        
        let switchesControllerFrame = CGRect(
            x: CGRectGetMaxX(visualizationFrame),
            y: bodyBounds.origin.y,
            width: bodyBounds.size.width - visualizationFrame.size.width,
            height: bodyBounds.size.height
        )
        _switchesController.view.frame = switchesControllerFrame
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
    
    // MARK: API
    
    var devices: [WemoDevice] = []
    {
        didSet
        {
            _switchesController.devices = devices
            _updateVisualization(false)
        }
    }
    
    // MARK: SwitchesViewControllerDelegate
    
    func switchesViewControllerDidToggleDevice(controller: SwitchesViewController, device: WemoDevice)
    {
        _updateVisualization(true)
    }
    
    // MARK: Internal
    
    internal func _updateVisualization(animated: Bool)
    {
        var activatedDevicesCount = 0
        for device in self.devices {
            if (device.state == .On) {
                ++activatedDevicesCount
            }
        }
        
        let percentageActivated = Float(activatedDevicesCount) / Float(self.devices.count)
        _visualizationController.setPercentActivated(percentageActivated, animated: animated)
    }
}

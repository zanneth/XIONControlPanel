//
//  MainViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SwitchesViewControllerDelegate {
    private var _server:                    WemoServer
    private var _visualizationController:   VisualizationViewController = VisualizationViewController()
    private var _switchesController:        SwitchesViewController = SwitchesViewController()
    private var _headerView:                HeaderView = HeaderView()
    private var _updateDevices:             Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        let url = NSURL(string: "http://midna.xionsf.com:5000")
        _server = WemoServer(url!)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
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
        
        _updateConnectivityStatus(.Disconnected)
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
            width: rint(0.55 * bodyBounds.size.width),
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
        super.viewDidAppear(animated)
        
        _headerView.xionLogoView.beginAnimating()
        
        if (!_server.connected) {
            _updateConnectivityStatus(.Connecting)
            _server.connect { (error: NSError?) -> Void in
                if (error == nil) {
                    self._reloadDevices()
                    self._startUpdatingDevices()
                } else {
                    self._updateConnectivityStatus(.Error)
                }
            }
        }
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
    
    func switchesViewControllerDidToggleDevices(controller: SwitchesViewController, devices: [WemoDevice])
    {
        _updateVisualization(true)
        
        for device in devices {
            _server.toggleDevice(device, state: device.state, completion: { (error: NSError?) -> Void in })
        }
    }
    
    // MARK: Internal
    
    internal func _updateVisualization(animated: Bool)
    {
        var activatedDevicesCount = 0
        for device in self.devices {
            if (device.state == .On) {
                activatedDevicesCount += 1
            }
        }
        
        let percentageActivated = (self.devices.count > 0 ? Float(activatedDevicesCount) / Float(self.devices.count) : 0.0)
        if (percentageActivated != _visualizationController.percentActivated) {
            _visualizationController.setPercentActivated(percentageActivated, animated: animated)
        }
    }
    
    internal func _updateConnectivityStatus(status: ConnectionStatus)
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self._headerView.connectionStatusView.connectivityStatus = status
            self._visualizationController.connectionStatus = status
        }
    }
    
    internal func _reloadDevices()
    {
        _server.fetchDevices({ (devices: [WemoDevice], error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if (error == nil) {
                    self.devices = devices
                    self._updateConnectivityStatus(.Connected)
                } else {
                    self.devices = []
                    self._updateConnectivityStatus(.Error)
                }
            }
        })
    }
    
    internal func _startUpdatingDevices()
    {
        _updateDevices = true
        
        let interval = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        dispatch_after(interval, dispatch_get_main_queue()) { () -> Void in
            if (self._updateDevices) {
                self._reloadDevices()
                self._startUpdatingDevices()
            }
        }
    }
    
    internal func _stopUpdatingDevices()
    {
        _updateDevices = false
    }
}

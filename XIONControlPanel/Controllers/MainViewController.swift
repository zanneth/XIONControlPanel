//
//  MainViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, SwitchesViewControllerDelegate
{
    fileprivate var _server:                    WemoServer
    fileprivate var _visualizationController:   VisualizationViewController = VisualizationViewController()
    fileprivate var _switchesController:        SwitchesViewController = SwitchesViewController()
    fileprivate var _headerView:                HeaderView = HeaderView()
    fileprivate var _updateDevices:             Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        let url = URL(string: "http://localhost:5000")
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
        
        self.view.backgroundColor = UIColor.black
        
        self.addChildViewController(_visualizationController)
        self.view.addSubview(_visualizationController.view)
        
        _switchesController.delegate = self
        self.addChildViewController(_switchesController)
        self.view.addSubview(_switchesController.view)
        
        self.view.addSubview(_headerView)
        
        _updateConnectivityStatus(.disconnected)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        let horizontalSizeClass = self.traitCollection.horizontalSizeClass
        
        let headerBounds = CGRect(
            x: 0.0,
            y: 0.0,
            width: bounds.size.width,
            height: rint(bounds.size.height / 8.0)
        )
        let bodyBounds = CGRect(
            x: 0.0,
            y: headerBounds.maxY,
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
        
        var switchesOriginX: CGFloat = 0.0
        var switchesWidth: CGFloat = 0.0
        if (horizontalSizeClass == .regular) {
            switchesOriginX = visualizationFrame.maxX
            switchesWidth = bodyBounds.size.width - visualizationFrame.size.width
        } else {
            switchesOriginX = 0.0
            switchesWidth = bodyBounds.size.width
        }
        
        let switchesControllerFrame = CGRect(
            x: switchesOriginX,
            y: bodyBounds.origin.y,
            width: switchesWidth,
            height: bodyBounds.size.height
        )
        _switchesController.view.frame = switchesControllerFrame
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        _headerView.xionLogoView.beginAnimating()
        
        if (!_server.connected) {
            _updateConnectivityStatus(.connecting)
            _server.connect { (error: Error?) -> Void in
                if (error == nil) {
                    self._reloadDevices()
                    self._startUpdatingDevices()
                } else {
                    self._updateConnectivityStatus(.error)
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        _updateSizeClassPresentation()
    }
    
    override var prefersStatusBarHidden : Bool
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
    
    func switchesViewControllerDidToggleDevices(_ controller: SwitchesViewController, devices: [WemoDevice])
    {
        _updateVisualization(true)
        
        for device in devices {
            _server.toggleDevice(device, state: device.state, completion: { (error: Error?) -> Void in })
        }
    }
    
    // MARK: Internal
    
    internal func _updateSizeClassPresentation()
    {
        let horizontalSizeClass = self.traitCollection.horizontalSizeClass
        if (horizontalSizeClass == .regular) {
            _visualizationController.view.isHidden = false
        } else {
            _visualizationController.view.isHidden = true
        }
    }
    
    internal func _updateVisualization(_ animated: Bool)
    {
        var activatedDevicesCount = 0
        for device in self.devices {
            if (device.state == .on) {
                activatedDevicesCount += 1
            }
        }
        
        let percentageActivated = (self.devices.count > 0 ? Float(activatedDevicesCount) / Float(self.devices.count) : 0.0)
        if (percentageActivated != _visualizationController.percentActivated) {
            _visualizationController.setPercentActivated(percentageActivated, animated: animated)
        }
    }
    
    internal func _updateConnectivityStatus(_ status: ConnectionStatus)
    {
        DispatchQueue.main.async { () -> Void in
            self._headerView.connectionStatusView.connectivityStatus = status
            self._headerView.setNeedsLayout()
            self._visualizationController.connectionStatus = status
        }
    }
    
    internal func _reloadDevices()
    {
        _server.fetchDevices({ (devices: [WemoDevice], error: Error?) -> Void in
            DispatchQueue.main.async { () -> Void in
                if (error == nil) {
                    self.devices = devices
                    self._updateConnectivityStatus(.connected)
                } else {
                    self.devices = []
                    self._updateConnectivityStatus(.error)
                }
            }
        })
    }
    
    internal func _startUpdatingDevices()
    {
        _updateDevices = true
        
        let interval = DispatchTime.now() + Double(Int64(10 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: interval) { () -> Void in
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

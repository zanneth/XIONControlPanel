//
//  SwitchesViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/30/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Darwin
import Foundation
import UIKit

protocol SwitchesViewControllerDelegate: class {
    func switchesViewControllerDidToggleDevice(controller: SwitchesViewController, device: WemoDevice)
}

extension SwitchesViewControllerDelegate {
    func switchesViewControllerDidToggleDevice(controller: SwitchesViewController, device: WemoDevice) {}
}

class SwitchesViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
    weak var delegate:           SwitchesViewControllerDelegate?
    
    private var _collectionView:        UICollectionView = UICollectionView(frame: CGRectZero,
                                                                            collectionViewLayout: UICollectionViewFlowLayout())
    private var _currentDevicesHash:    UInt = 0
    
    static private let collectionViewCellReuseIdentifier = "SwitchesCollectionViewReuseID"
    static private let collectionViewCellsSpacing: CGFloat = 5.0
    static private let collectionViewCellsPerRow = 3
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let reuseID = SwitchesViewController.collectionViewCellReuseIdentifier
        let layout = _collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = SwitchesViewController.collectionViewCellsSpacing
        layout.minimumInteritemSpacing = SwitchesViewController.collectionViewCellsSpacing
        
        _collectionView.backgroundColor = UIColor.blackColor()
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.registerClass(WemoDeviceCellView.self, forCellWithReuseIdentifier: reuseID)
        self.view.addSubview(_collectionView)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        _collectionView.frame = bounds
    }
    
    // MARK: API
    
    var devices: [WemoDevice] = []
    {
        didSet
        {
            var devicesHash: UInt = 0
            for device in devices {
                devicesHash += UInt(device.serial.hash)
            }
            
            if (_currentDevicesHash != devicesHash) {
                _collectionView.reloadData()
                _currentDevicesHash = devicesHash
            }
        }
    }
    
    // MARK: UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.devices.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let reuseID = SwitchesViewController.collectionViewCellReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! WemoDeviceCellView
        
        let device = self.devices[indexPath.row]
        cell.device = device
        cell.ordinal = indexPath.row + 1
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let spacing = SwitchesViewController.collectionViewCellsSpacing
        let cellsPerRow = CGFloat(SwitchesViewController.collectionViewCellsPerRow)
        let dimensions = rint(collectionView.bounds.size.width / cellsPerRow) - spacing
        return CGSize(width: dimensions, height: dimensions)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! WemoDeviceCellView
        cell.toggled = !cell.toggled
        
        let device = self.devices[indexPath.row]
        device.state = (cell.toggled ? .On : .Off)
        
        self.delegate?.switchesViewControllerDidToggleDevice(self, device: device)
    }
}

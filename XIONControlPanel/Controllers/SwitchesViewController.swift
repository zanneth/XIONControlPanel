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

protocol SwitchesViewControllerDelegate: class
{
    func switchesViewControllerDidToggleDevices(controller: SwitchesViewController, devices: [WemoDevice])
}

extension SwitchesViewControllerDelegate
{
    func switchesViewControllerDidToggleDevices(controller: SwitchesViewController, devices: [WemoDevice]) {}
}

class SwitchesViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
    weak var delegate:                  SwitchesViewControllerDelegate?
    private var _collectionView:        UICollectionView = UICollectionView(frame: CGRectZero,
                                                                            collectionViewLayout: UICollectionViewFlowLayout())
    private var _currentDevicesHash:    Int = 0
    
    static private let collectionViewDeviceSwitchCellReuseIdentifier = "DeviceSwitchReuseID"
    static private let collectionViewActionCellReuseIdentifier = "ActionCellReuseID"
    static private let collectionViewCellsSpacing: CGFloat = 5.0
    
    private enum ActionCell: Int
    {
        case AllOn
        case AllOff
        
        func name() -> String
        {
            switch self {
            case .AllOn:
                return "All On"
            case .AllOff:
                return "All Off"
            }
        }
        
        static let count: Int = {
            var max = 0
            while let _ = ActionCell(rawValue: max) { max += 1 }
            return max
        }()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let deviceCellReuseID = SwitchesViewController.collectionViewDeviceSwitchCellReuseIdentifier
        let actionCellReuseID = SwitchesViewController.collectionViewActionCellReuseIdentifier
        let layout = _collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = SwitchesViewController.collectionViewCellsSpacing
        layout.minimumLineSpacing = SwitchesViewController.collectionViewCellsSpacing
        
        _collectionView.backgroundColor = UIColor.blackColor()
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.registerClass(WemoDeviceCellView.self, forCellWithReuseIdentifier: deviceCellReuseID)
        _collectionView.registerClass(WemoActionCellView.self, forCellWithReuseIdentifier: actionCellReuseID)
        self.view.addSubview(_collectionView)
        
        self.devices = []
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
            // sort devices by name
            self.devices.sortInPlace({ (d1: WemoDevice, d2: WemoDevice) -> Bool in
                return (d1.name.compare(d2.name) == .OrderedAscending)
            })
            
            let hash = self.devices.reduce(0, combine: {$0 ^ $1.hashValue})
            if (hash != _currentDevicesHash) {
                let previousSet = NSOrderedSet(array: oldValue)
                let newSet = NSOrderedSet(array: self.devices)
                var insertedIndexPaths: [NSIndexPath] = []
                var updatedIndexPaths: [NSIndexPath] = []
                var deletedIndexPaths: [NSIndexPath] = []
                
                // if we have devices now and we didn't before, or vice versa,
                // we need to update the action cells
                if ((oldValue.count == 0 && self.devices.count != 0) || (self.devices.count == 0 && oldValue.count != 0)) {
                    for actionCellIdx in 0 ..< ActionCell.count {
                        let actionCellIndexPath = NSIndexPath(forItem: actionCellIdx, inSection: 0)
                        updatedIndexPaths.append(actionCellIndexPath)
                    }
                }
                
                // find deletes and updates
                for (idx, device) in previousSet.enumerate() {
                    let itemIndex = idx + ActionCell.count
                    let curIndexPath = NSIndexPath(forItem: itemIndex, inSection: 0)
                    
                    if (!newSet.containsObject(device)) {
                        deletedIndexPaths.append(curIndexPath)
                    } else if (idx < newSet.count) {
                        let deviceInNewSet = newSet.objectAtIndex(idx) as! WemoDevice
                        if (deviceInNewSet != (device as! WemoDevice)) {
                            updatedIndexPaths.append(curIndexPath)
                        }
                    }
                }
                
                // find insertions
                for (idx, device) in newSet.enumerate() {
                    if (!previousSet.containsObject(device)) {
                        let itemIndex = idx + ActionCell.count
                        let insertedIndexPath = NSIndexPath(forItem: itemIndex, inSection: 0)
                        insertedIndexPaths.append(insertedIndexPath)
                    }
                }
                
                UIView.performWithoutAnimation { () -> Void in
                    self._collectionView.performBatchUpdates({ () -> Void in
                        self._collectionView.deleteItemsAtIndexPaths(deletedIndexPaths)
                        self._collectionView.reloadItemsAtIndexPaths(updatedIndexPaths)
                        self._collectionView.insertItemsAtIndexPaths(insertedIndexPaths)
                    }, completion: nil)
                }
                
                _currentDevicesHash = hash
            }
        }
    }
    
    // MARK: UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.devices.count + ActionCell.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        if (indexPath.item < ActionCell.count) {
            let reuseID = SwitchesViewController.collectionViewActionCellReuseIdentifier
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! WemoActionCellView
            cell.textLabel.text = ActionCell(rawValue: indexPath.item)?.name().uppercaseString
            cell.enabled = (self.devices.count > 0)
            
            return cell
        } else {
            let reuseID = SwitchesViewController.collectionViewDeviceSwitchCellReuseIdentifier
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! WemoDeviceCellView
            
            let device = _deviceAtIndexPath(indexPath)
            cell.deviceName = device.name
            cell.toggled = (device.state == .On)
            cell.ordinal = indexPath.item - ActionCell.count + 1
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let spacing = SwitchesViewController.collectionViewCellsSpacing
        let bounds = collectionView.bounds
        var cellsPerRow: CGFloat = 0.0
        
        switch (self.traitCollection.horizontalSizeClass) {
        case .Regular, .Compact where (bounds.size.width >= 400.0):
            cellsPerRow = 3.0
            break
        case .Compact:
            cellsPerRow = 2.0
        default:
            cellsPerRow = 2.0
        }
        
        let dimensions = floor((collectionView.bounds.size.width / cellsPerRow) - ((spacing * (cellsPerRow - 1.0)) / cellsPerRow))
        if (indexPath.item < ActionCell.count) {
            return CGSize(width: collectionView.bounds.size.width, height: rint(dimensions / 2.0))
        } else {
            return CGSize(width: dimensions, height: dimensions)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.item < ActionCell.count) {
            let tappedActionCell = ActionCell(rawValue: indexPath.item)
            var currentDelay: NSTimeInterval = 0.0
            
            for i in ActionCell.count ..< collectionView.numberOfItemsInSection(indexPath.section) {
                let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: indexPath.section)) as! WemoDeviceCellView
                let animOptions = UIViewAnimationOptions([.AllowUserInteraction])
                
                UIView.animateWithDuration(0.3, delay: currentDelay, options: animOptions, animations: {
                    cell.toggled = (tappedActionCell == .AllOn)
                }, completion: nil)
                
                currentDelay += 0.05
            }
            
            for device in self.devices {
                device.state = (tappedActionCell == .AllOn ? .On : .Off)
            }
            
            self.delegate?.switchesViewControllerDidToggleDevices(self, devices: self.devices)
        } else {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! WemoDeviceCellView
            cell.toggled = !cell.toggled
            
            let device = _deviceAtIndexPath(indexPath)
            device.state = (cell.toggled ? .On : .Off)
            
            self.delegate?.switchesViewControllerDidToggleDevices(self, devices: [device])
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if (indexPath.item < ActionCell.count) {
            return (self.devices.count > 0)
        } else {
            return true
        }
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if (indexPath.item < ActionCell.count) {
            return (self.devices.count > 0)
        } else {
            return true
        }
    }
    
    // MARK: Internal
    
    internal func _deviceAtIndexPath(indexPath: NSIndexPath) -> WemoDevice
    {
        let deviceIdx = indexPath.item - ActionCell.count
        let device = self.devices[deviceIdx]
        return device
    }
}

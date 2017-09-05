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
    func switchesViewControllerDidToggleDevices(_ controller: SwitchesViewController, devices: [WemoDevice])
}

extension SwitchesViewControllerDelegate
{
    func switchesViewControllerDidToggleDevices(_ controller: SwitchesViewController, devices: [WemoDevice]) {}
}

class SwitchesViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
    weak var delegate:                  SwitchesViewControllerDelegate?
    fileprivate var _collectionView:        UICollectionView = UICollectionView(frame: CGRect.zero,
                                                                            collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var _currentDevicesHash:    Int = 0
    
    static fileprivate let collectionViewDeviceSwitchCellReuseIdentifier = "DeviceSwitchReuseID"
    static fileprivate let collectionViewActionCellReuseIdentifier = "ActionCellReuseID"
    static fileprivate let collectionViewCellsSpacing: CGFloat = 5.0
    
    fileprivate enum ActionCell: Int
    {
        case allOn
        case allOff
        
        func name() -> String
        {
            switch self {
            case .allOn:
                return "All On"
            case .allOff:
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
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = SwitchesViewController.collectionViewCellsSpacing
        layout.minimumLineSpacing = SwitchesViewController.collectionViewCellsSpacing
        
        _collectionView.backgroundColor = UIColor.black
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.register(WemoDeviceCellView.self, forCellWithReuseIdentifier: deviceCellReuseID)
        _collectionView.register(WemoActionCellView.self, forCellWithReuseIdentifier: actionCellReuseID)
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
            self.devices.sort(by: { (d1: WemoDevice, d2: WemoDevice) -> Bool in
                return (d1.name.compare(d2.name) == .orderedAscending)
            })
            
            let hash = self.devices.reduce(0, {$0 ^ $1.hashValue})
            if (hash != _currentDevicesHash) {
                let previousSet = NSOrderedSet(array: oldValue)
                let newSet = NSOrderedSet(array: self.devices)
                var insertedIndexPaths: [IndexPath] = []
                var updatedIndexPaths: [IndexPath] = []
                var deletedIndexPaths: [IndexPath] = []
                
                // if we have devices now and we didn't before, or vice versa,
                // we need to update the action cells
                if ((oldValue.count == 0 && self.devices.count != 0) || (self.devices.count == 0 && oldValue.count != 0)) {
                    for actionCellIdx in 0 ..< ActionCell.count {
                        let actionCellIndexPath = IndexPath(item: actionCellIdx, section: 0)
                        updatedIndexPaths.append(actionCellIndexPath)
                    }
                }
                
                // find deletes and updates
                for (idx, device) in previousSet.enumerated() {
                    let itemIndex = idx + ActionCell.count
                    let curIndexPath = IndexPath(item: itemIndex, section: 0)
                    
                    if (!newSet.contains(device)) {
                        deletedIndexPaths.append(curIndexPath)
                    } else if (idx < newSet.count) {
                        let deviceInNewSet = newSet.object(at: idx) as! WemoDevice
                        if (deviceInNewSet != (device as! WemoDevice)) {
                            updatedIndexPaths.append(curIndexPath)
                        }
                    }
                }
                
                // find insertions
                for (idx, device) in newSet.enumerated() {
                    if (!previousSet.contains(device)) {
                        let itemIndex = idx + ActionCell.count
                        let insertedIndexPath = IndexPath(item: itemIndex, section: 0)
                        insertedIndexPaths.append(insertedIndexPath)
                    }
                }
                
                UIView.performWithoutAnimation { () -> Void in
                    self._collectionView.performBatchUpdates({ () -> Void in
                        self._collectionView.deleteItems(at: deletedIndexPaths)
                        self._collectionView.reloadItems(at: updatedIndexPaths)
                        self._collectionView.insertItems(at: insertedIndexPaths)
                    }, completion: nil)
                }
                
                _currentDevicesHash = hash
            }
        }
    }
    
    // MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.devices.count + ActionCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if (indexPath.item < ActionCell.count) {
            let reuseID = SwitchesViewController.collectionViewActionCellReuseIdentifier
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! WemoActionCellView
            cell.textLabel.text = ActionCell(rawValue: indexPath.item)?.name().uppercased()
            cell.enabled = (self.devices.count > 0)
            
            return cell
        } else {
            let reuseID = SwitchesViewController.collectionViewDeviceSwitchCellReuseIdentifier
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! WemoDeviceCellView
            
            let device = _deviceAtIndexPath(indexPath)
            cell.deviceName = device.name
            cell.toggled = (device.state == .on)
            cell.ordinal = indexPath.item - ActionCell.count + 1
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let spacing = SwitchesViewController.collectionViewCellsSpacing
        let bounds = collectionView.bounds
        var cellsPerRow: CGFloat = 0.0
        
        switch (self.traitCollection.horizontalSizeClass) {
        case .regular where (bounds.size.width >= 400.0),
             .compact where (bounds.size.width >= 400.0):
            cellsPerRow = 3.0
            break
        case .compact:
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (indexPath.item < ActionCell.count) {
            let tappedActionCell = ActionCell(rawValue: indexPath.item)
            var currentDelay: TimeInterval = 0.0
            
            for i in ActionCell.count ..< collectionView.numberOfItems(inSection: indexPath.section) {
                if let cell = collectionView.cellForItem(at: IndexPath(item: i, section: indexPath.section)) as? WemoDeviceCellView {
                    let animOptions = UIViewAnimationOptions([.allowUserInteraction])
                    
                    UIView.animate(withDuration: 0.3, delay: currentDelay, options: animOptions, animations: {
                        cell.toggled = (tappedActionCell == .allOn)
                    }, completion: nil)
                    
                    currentDelay += 0.05
                }
            }
            
            for device in self.devices {
                device.state = (tappedActionCell == .allOn ? .on : .off)
            }
            
            self.delegate?.switchesViewControllerDidToggleDevices(self, devices: self.devices)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as! WemoDeviceCellView
            cell.toggled = !cell.toggled
            
            let device = _deviceAtIndexPath(indexPath)
            device.state = (cell.toggled ? .on : .off)
            
            self.delegate?.switchesViewControllerDidToggleDevices(self, devices: [device])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        if (indexPath.item < ActionCell.count) {
            return (self.devices.count > 0)
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        if (indexPath.item < ActionCell.count) {
            return (self.devices.count > 0)
        } else {
            return true
        }
    }
    
    // MARK: Internal
    
    internal func _deviceAtIndexPath(_ indexPath: IndexPath) -> WemoDevice
    {
        let deviceIdx = indexPath.item - ActionCell.count
        let device = self.devices[deviceIdx]
        return device
    }
}

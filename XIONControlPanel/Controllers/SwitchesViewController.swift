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
    func switchesViewControllerDidToggleDevices(controller: SwitchesViewController, devices: [WemoDevice])
}

extension SwitchesViewControllerDelegate {
    func switchesViewControllerDidToggleDevices(controller: SwitchesViewController, devices: [WemoDevice]) {}
}

class SwitchesViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
    weak var delegate:                  SwitchesViewControllerDelegate?
    private var _collectionView:        UICollectionView = UICollectionView(frame: CGRectZero,
                                                                            collectionViewLayout: UICollectionViewFlowLayout())
    
    static private let collectionViewDeviceSwitchCellReuseIdentifier = "DeviceSwitchReuseID"
    static private let collectionViewActionCellReuseIdentifier = "ActionCellReuseID"
    static private let collectionViewCellsSpacing: CGFloat = 5.0
    static private let collectionViewCellsPerRow = 3
    
    private enum ActionCell: Int {
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
            while let _ = ActionCell(rawValue: max) { ++max }
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
        layout.minimumLineSpacing = SwitchesViewController.collectionViewCellsSpacing
        layout.minimumInteritemSpacing = SwitchesViewController.collectionViewCellsSpacing
        
        _collectionView.backgroundColor = UIColor.blackColor()
        _collectionView.delegate = self
        _collectionView.dataSource = self
        _collectionView.registerClass(WemoDeviceCellView.self, forCellWithReuseIdentifier: deviceCellReuseID)
        _collectionView.registerClass(WemoActionCellView.self, forCellWithReuseIdentifier: actionCellReuseID)
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
            _collectionView.reloadData()
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
            
            return cell
        } else {
            let reuseID = SwitchesViewController.collectionViewDeviceSwitchCellReuseIdentifier
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! WemoDeviceCellView
            
            let deviceIdx = indexPath.item - ActionCell.count
            let device = self.devices[deviceIdx]
            cell.device = device
            cell.ordinal = deviceIdx + 1
            
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let spacing = SwitchesViewController.collectionViewCellsSpacing
        let cellsPerRow = CGFloat(SwitchesViewController.collectionViewCellsPerRow)
        let dimensions = rint(collectionView.bounds.size.width / cellsPerRow) - spacing
        
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
            for var i = ActionCell.count; i < collectionView.numberOfItemsInSection(indexPath.section); ++i {
                let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: indexPath.section)) as! WemoDeviceCellView
                
                UIView.animateWithDuration(0.3, delay: currentDelay, options: UIViewAnimationOptions(), animations: { () -> Void in
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
            
            let deviceIdx = indexPath.item - ActionCell.count
            let device = self.devices[deviceIdx]
            device.state = (cell.toggled ? .On : .Off)
            
            self.delegate?.switchesViewControllerDidToggleDevices(self, devices: [device])
        }
    }
}

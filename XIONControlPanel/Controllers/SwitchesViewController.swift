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

class SwitchesViewController: UIViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout
{
    private var _collectionView: UICollectionView = UICollectionView(frame: CGRectZero,
                                                                     collectionViewLayout: UICollectionViewFlowLayout())
    
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
    
    // MARK: UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let reuseID = SwitchesViewController.collectionViewCellReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! WemoDeviceCellView
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
}

//
//  WemoDeviceCellView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class WemoDeviceCellView: UICollectionViewCell {
    private var _device:        WemoDevice?
    private var _ordinal:       Int = 0
    private var _nameLabel:     UILabel = UILabel()
    private var _ordinalLabel:  UILabel = UILabel()
    private var _indicator:     SwitchIndicatorView = SwitchIndicatorView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        let annotationsColor = UIColor.darkGrayColor()
        self.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        _nameLabel.font = UIFont(name: "Orbitron-Medium", size: 16.0)
        _nameLabel.numberOfLines = 3
        _nameLabel.textColor = UIColor.whiteColor()
        _nameLabel.text = "beatmania IIDX".uppercaseString
        self.addSubview(_nameLabel)
        
        _ordinalLabel.font = UIFont(name: "Orbitron-Medium", size: 21.0)
        _ordinalLabel.textColor = annotationsColor
        _ordinalLabel.text = "00"
        self.addSubview(_ordinalLabel)
        
        _indicator.foregroundColor = annotationsColor
        self.addSubview(_indicator)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    // MARK: Overrides
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let padding: CGFloat = 10.0
        
        _indicator.frame = CGRect(
            x: padding,
            y: padding,
            width: 20.0,
            height: 20.0
        )
        
        let nameLabelSize = _nameLabel.sizeThatFits(CGSize(width: bounds.size.width - padding * 2.0, height: bounds.size.height - padding))
        _nameLabel.frame = CGRect(
            x: padding,
            y: bounds.size.height - nameLabelSize.height - padding,
            width: nameLabelSize.width,
            height: nameLabelSize.height
        )
        
        let ordinalLabelSize = _ordinalLabel.sizeThatFits(bounds.size)
        _ordinalLabel.frame = CGRect(
            x: bounds.size.width - ordinalLabelSize.width - padding,
            y: padding,
            width: ordinalLabelSize.width,
            height: ordinalLabelSize.height
        )
    }

    // MARK: API
    
    var device: WemoDevice? {
        get
        {
            return _device
        }
        
        set(device)
        {
            _device = device
            _nameLabel.text = _device?.name
        }
    }
    
    var ordinal: Int {
        get
        {
            return _ordinal
        }
        
        set(ordinal)
        {
            _ordinal = ordinal
            _ordinalLabel.text = String(format: "%.2d", _ordinal)
        }
    }
}

//
//  WemoDeviceCellView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class WemoDeviceCellView: UICollectionViewCell {
    private var _device:                WemoDevice?
    private var _ordinal:               Int = 0
    private var _selectionOverlayView:  UIView = UIView()
    private var _nameLabel:             UILabel = UILabel()
    private var _ordinalLabel:          UILabel = UILabel()
    private var _indicator:             SwitchIndicatorView = SwitchIndicatorView()
    
    static private var disabledBackgroundColor = UIColor(white: 0.2, alpha: 1.0)
    static private var enabledBackgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
    static private var disabledAnnotationsColor = UIColor.darkGrayColor()
    static private var enabledAnnotationsColor = UIColor.blackColor()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = WemoDeviceCellView.disabledBackgroundColor
        
        _selectionOverlayView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(_selectionOverlayView)
        
        _nameLabel.font = UIFont(name: "Orbitron-Medium", size: 16.0)
        _nameLabel.numberOfLines = 3
        _nameLabel.textColor = UIColor.whiteColor()
        self.contentView.addSubview(_nameLabel)
        
        _ordinalLabel.font = UIFont(name: "Orbitron-Medium", size: 21.0)
        _ordinalLabel.textColor = WemoDeviceCellView.disabledAnnotationsColor
        _ordinalLabel.text = "00"
        self.contentView.addSubview(_ordinalLabel)
        
        _indicator.foregroundColor = WemoDeviceCellView.disabledAnnotationsColor
        self.contentView.addSubview(_indicator)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    // MARK: Overrides
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.contentView.bounds
        let padding: CGFloat = 10.0
        
        _selectionOverlayView.frame = bounds
        
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
    
    override var highlighted: Bool {
        didSet
        {
            if (self.highlighted) {
                _selectionOverlayView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            } else {
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self._selectionOverlayView.backgroundColor = UIColor.clearColor()
                })
            }
        }
    }

    // MARK: API
    
    var device: WemoDevice?
    {
        get
        {
            return _device
        }
        
        set(device)
        {
            _device = device
            _nameLabel.text = _device?.name.uppercaseString
        }
    }
    
    var ordinal: Int
    {
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
    
    var toggled: Bool
    {
        get
        {
            return (_device?.state == .On)
        }
        
        set(toggled)
        {
            _device?.state = (toggled ? .On : .Off)
            _indicator.status = toggled
            
            if (toggled) {
                self.contentView.backgroundColor = WemoDeviceCellView.enabledBackgroundColor
                _indicator.foregroundColor = WemoDeviceCellView.enabledAnnotationsColor
                _ordinalLabel.textColor = WemoDeviceCellView.enabledAnnotationsColor
            } else {
                self.contentView.backgroundColor = WemoDeviceCellView.disabledBackgroundColor
                _indicator.foregroundColor = WemoDeviceCellView.disabledAnnotationsColor
                _ordinalLabel.textColor = WemoDeviceCellView.disabledAnnotationsColor
            }
        }
    }
}

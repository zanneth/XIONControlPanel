//
//  WemoDeviceView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

public class WemoCellView: UICollectionViewCell {
    private var _selectionOverlayView:  UIView = UIView()
    
    static private var disabledBackgroundColor = UIColor(white: 0.2, alpha: 1.0)
    static private var enabledBackgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = WemoCellView.disabledBackgroundColor
        
        _selectionOverlayView.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(_selectionOverlayView)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    // MARK: Overrides
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.contentView.bounds
        _selectionOverlayView.frame = bounds
    }
    
    override public var highlighted: Bool {
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
}

public class WemoDeviceCellView: WemoCellView {
    private var _ordinal:               Int = 0
    private var _nameLabel:             UILabel = UILabel()
    private var _ordinalLabel:          UILabel = UILabel()
    private var _indicator:             SwitchIndicatorView = SwitchIndicatorView()
    
    static private var disabledAnnotationsColor = UIColor.darkGrayColor()
    static private var enabledAnnotationsColor = UIColor.blackColor()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        _nameLabel.font = UIFont(name: "Orbitron-Medium", size: 16.0)
        _nameLabel.numberOfLines = 3
        _nameLabel.allowsDefaultTighteningForTruncation = true
        _nameLabel.adjustsFontSizeToFitWidth = true
        _nameLabel.textColor = UIColor.whiteColor()
        self.contentView.addSubview(_nameLabel)
        
        _ordinalLabel.font = UIFont(name: "Orbitron-Medium", size: 21.0)
        _ordinalLabel.textColor = WemoDeviceCellView.disabledAnnotationsColor
        _ordinalLabel.text = "00"
        self.contentView.addSubview(_ordinalLabel)
        
        _indicator.foregroundColor = WemoDeviceCellView.disabledAnnotationsColor
        self.contentView.addSubview(_indicator)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    // MARK: Overrides
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.contentView.bounds
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
    
    var deviceName: String = ""
    {
        didSet
        {
            _nameLabel.text = self.deviceName.uppercaseString
            self.setNeedsLayout()
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
            self.setNeedsLayout()
        }
    }
    
    var toggled: Bool = false
    {
        didSet
        {
            _indicator.status = toggled
            
            if (toggled) {
                self.contentView.backgroundColor = WemoCellView.enabledBackgroundColor
                _indicator.foregroundColor = WemoDeviceCellView.enabledAnnotationsColor
                _ordinalLabel.textColor = WemoDeviceCellView.enabledAnnotationsColor
            } else {
                self.contentView.backgroundColor = WemoCellView.disabledBackgroundColor
                _indicator.foregroundColor = WemoDeviceCellView.disabledAnnotationsColor
                _ordinalLabel.textColor = WemoDeviceCellView.disabledAnnotationsColor
            }
        }
    }
}

public class WemoActionCellView: WemoCellView {
    var textLabel: UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.textLabel.font = UIFont(name: "Orbitron-Medium", size: 21.0)
        self.textLabel.textColor = UIColor.whiteColor()
        self.textLabel.textAlignment = .Center
        self.addSubview(self.textLabel)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        self.textLabel.frame = self.bounds
    }
    
    var enabled: Bool = true
    {
        didSet
        {
            if (enabled) {
                self.textLabel.textColor = UIColor.whiteColor()
            } else {
                self.textLabel.textColor = UIColor.darkGrayColor()
            }
        }
    }
}

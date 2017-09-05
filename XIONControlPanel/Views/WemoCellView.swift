//
//  WemoDeviceView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

open class WemoCellView: UICollectionViewCell
{
    fileprivate var _selectionOverlayView:  UIView = UIView()
    
    static fileprivate var disabledBackgroundColor = UIColor(white: 0.2, alpha: 1.0)
    static fileprivate var enabledBackgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = WemoCellView.disabledBackgroundColor
        
        _selectionOverlayView.backgroundColor = UIColor.clear
        self.contentView.addSubview(_selectionOverlayView)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    // MARK: Overrides
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.contentView.bounds
        _selectionOverlayView.frame = bounds
    }
    
    override open var isHighlighted: Bool {
        didSet
        {
            if (self.isHighlighted) {
                _selectionOverlayView.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
            } else {
                let animOptions = UIViewAnimationOptions([.allowUserInteraction])
                UIView.animate(withDuration: 1.0, delay: 0.0, options: animOptions, animations: {
                    self._selectionOverlayView.backgroundColor = UIColor.clear
                }, completion: nil)
            }
        }
    }
}

open class WemoDeviceCellView: WemoCellView
{
    fileprivate var _ordinal:               Int = 0
    fileprivate var _nameLabel:             UILabel = UILabel()
    fileprivate var _ordinalLabel:          UILabel = UILabel()
    fileprivate var _indicator:             SwitchIndicatorView = SwitchIndicatorView()
    
    static fileprivate var disabledAnnotationsColor = UIColor.darkGray
    static fileprivate var enabledAnnotationsColor = UIColor.black
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        _nameLabel.font = UIFont(name: "Orbitron-Medium", size: 16.0)
        _nameLabel.numberOfLines = 3
        _nameLabel.allowsDefaultTighteningForTruncation = true
        _nameLabel.adjustsFontSizeToFitWidth = true
        _nameLabel.textColor = UIColor.white
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
    
    override open func layoutSubviews()
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
            _nameLabel.text = self.deviceName.uppercased()
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

open class WemoActionCellView: WemoCellView
{
    var textLabel: UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.textLabel.font = UIFont(name: "Orbitron-Medium", size: 21.0)
        self.textLabel.textColor = UIColor.white
        self.textLabel.textAlignment = .center
        self.addSubview(self.textLabel)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        self.textLabel.frame = self.bounds
    }
    
    var enabled: Bool = true
    {
        didSet
        {
            if (enabled) {
                self.textLabel.textColor = UIColor.white
            } else {
                self.textLabel.textColor = UIColor.darkGray
            }
        }
    }
}

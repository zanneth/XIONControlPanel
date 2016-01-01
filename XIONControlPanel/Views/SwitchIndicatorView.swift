//
//  SwitchIndicatorView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class SwitchIndicatorView: UIView {
    private var _status:            Bool = false
    private var _foregroundColor:   UIColor = UIColor.whiteColor()
    private var _outerCircleLayer:  CAShapeLayer = CAShapeLayer()
    private var _offSymbolLayer:    CAShapeLayer = CAShapeLayer()
    private var _onSymbolLayer:     CAShapeLayer = CAShapeLayer()
    
    static private var lineWidth: CGFloat = 2.0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        _outerCircleLayer.fillColor = UIColor.clearColor().CGColor
        _outerCircleLayer.lineWidth = SwitchIndicatorView.lineWidth
        
        _offSymbolLayer.fillColor = UIColor.clearColor().CGColor
        _offSymbolLayer.lineWidth = SwitchIndicatorView.lineWidth
        
        self.layer.addSublayer(_outerCircleLayer)
        self.layer.addSublayer(_offSymbolLayer)
        self.layer.addSublayer(_onSymbolLayer)
        
        self.status = false
        self.foregroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let lineWidth = SwitchIndicatorView.lineWidth
        
        _outerCircleLayer.frame = bounds
        _offSymbolLayer.frame = bounds
        _onSymbolLayer.frame = bounds
        
        _outerCircleLayer.path = CGPathCreateWithEllipseInRect(bounds, nil)
        
        let innerSize = CGSize(width: rint(bounds.size.width / 2.0), height: rint(bounds.size.height / 2.0))
        let innerBounds = CGRect(
            x: rint(bounds.size.width / 2.0 - innerSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - innerSize.height / 2.0),
            width: innerSize.width,
            height: innerSize.height
        )
        _offSymbolLayer.path = CGPathCreateWithEllipseInRect(innerBounds, nil)
        
        let onSymbolSize = CGSize(width: lineWidth, height: innerSize.height)
        let onSymbolRect = CGRect(
            x: rint(bounds.size.width / 2.0 - onSymbolSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - onSymbolSize.height / 2.0),
            width: onSymbolSize.width,
            height: onSymbolSize.height
        )
        _onSymbolLayer.path = CGPathCreateWithRect(onSymbolRect, nil)
    }
    
    // MARK: API
    
    var status: Bool
    {
        get
        {
            return _status
        }
        
        set(status)
        {
            _status = status
            _offSymbolLayer.hidden = _status
            _onSymbolLayer.hidden = !_status
        }
    }
    
    var foregroundColor: UIColor
    {
        get
        {
            return _foregroundColor
        }
        
        set(color)
        {
            _foregroundColor = color
            _outerCircleLayer.strokeColor = _foregroundColor.CGColor
            _offSymbolLayer.strokeColor = _foregroundColor.CGColor
            _onSymbolLayer.fillColor = _foregroundColor.CGColor
        }
    }
}

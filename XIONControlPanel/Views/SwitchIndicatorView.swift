//
//  SwitchIndicatorView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class SwitchIndicatorView: UIView
{
    fileprivate var _status:            Bool = false
    fileprivate var _foregroundColor:   UIColor = UIColor.white
    fileprivate var _outerCircleLayer:  CAShapeLayer = CAShapeLayer()
    fileprivate var _offSymbolLayer:    CAShapeLayer = CAShapeLayer()
    fileprivate var _onSymbolLayer:     CAShapeLayer = CAShapeLayer()
    
    static fileprivate var lineWidth: CGFloat = 2.0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        _outerCircleLayer.fillColor = UIColor.clear.cgColor
        _outerCircleLayer.lineWidth = SwitchIndicatorView.lineWidth
        
        _offSymbolLayer.fillColor = UIColor.clear.cgColor
        _offSymbolLayer.lineWidth = SwitchIndicatorView.lineWidth
        
        self.layer.addSublayer(_outerCircleLayer)
        self.layer.addSublayer(_offSymbolLayer)
        self.layer.addSublayer(_onSymbolLayer)
        
        self.status = false
        self.foregroundColor = UIColor.white
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
        
        _outerCircleLayer.path = CGPath(ellipseIn: bounds, transform: nil)
        
        let innerSize = CGSize(width: rint(bounds.size.width / 2.0), height: rint(bounds.size.height / 2.0))
        let innerBounds = CGRect(
            x: rint(bounds.size.width / 2.0 - innerSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - innerSize.height / 2.0),
            width: innerSize.width,
            height: innerSize.height
        )
        _offSymbolLayer.path = CGPath(ellipseIn: innerBounds, transform: nil)
        
        let onSymbolSize = CGSize(width: lineWidth, height: innerSize.height)
        let onSymbolRect = CGRect(
            x: rint(bounds.size.width / 2.0 - onSymbolSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - onSymbolSize.height / 2.0),
            width: onSymbolSize.width,
            height: onSymbolSize.height
        )
        _onSymbolLayer.path = CGPath(rect: onSymbolRect, transform: nil)
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
            _offSymbolLayer.isHidden = _status
            _onSymbolLayer.isHidden = !_status
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
            _outerCircleLayer.strokeColor = _foregroundColor.cgColor
            _offSymbolLayer.strokeColor = _foregroundColor.cgColor
            _onSymbolLayer.fillColor = _foregroundColor.cgColor
        }
    }
}

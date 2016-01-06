//
//  XIONLogoView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/30/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class XIONLogoView: UIView {
    private var _xionLogoImageView:         UIImageView = UIImageView()
    private var _logoInnerRingImageView:    UIImageView = UIImageView()
    private var _logoOuterRingImageView:    UIImageView = UIImageView()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        
        _xionLogoImageView.image = UIImage(named: "XIONLogoWithRing")
        _xionLogoImageView.contentMode = .ScaleAspectFit
        
        _logoInnerRingImageView.image = UIImage(named: "XIONLogoInnerRing")
        _logoInnerRingImageView.contentMode = .ScaleAspectFit
        
        _logoOuterRingImageView.image = UIImage(named: "XIONLogoOuterRing")
        _logoOuterRingImageView.contentMode = .ScaleAspectFit
        
        self.addSubview(_logoOuterRingImageView)
        self.addSubview(_logoInnerRingImageView)
        self.addSubview(_xionLogoImageView)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        _xionLogoImageView.frame = bounds
        _logoInnerRingImageView.frame = bounds
        _logoOuterRingImageView.frame = bounds
    }
    
    // MARK: API
    
    func beginAnimating()
    {
        self.stopAnimating()
        
        let duration: NSTimeInterval = 20.0
        
        let clockwiseAnim = CABasicAnimation(keyPath: "transform.rotation")
        clockwiseAnim.fromValue = 0.0
        clockwiseAnim.toValue = 2.0 * π
        clockwiseAnim.duration = duration
        clockwiseAnim.repeatCount = Float.infinity
        
        let counterClockwiseAnim = CABasicAnimation(keyPath: "transform.rotation")
        counterClockwiseAnim.fromValue = 2.0 * π
        counterClockwiseAnim.toValue = 0.0
        counterClockwiseAnim.duration = duration
        counterClockwiseAnim.repeatCount = Float.infinity
        
        _logoInnerRingImageView.layer.addAnimation(clockwiseAnim, forKey: "LogoClockwiseAnimation")
        _logoOuterRingImageView.layer.addAnimation(counterClockwiseAnim, forKey: "LogoCounterclockwiseAnimation")
    }
    
    func stopAnimating()
    {
        _logoInnerRingImageView.layer.removeAllAnimations()
        _logoOuterRingImageView.layer.removeAllAnimations()
    }
}

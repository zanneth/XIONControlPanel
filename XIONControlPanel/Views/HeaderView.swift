//
//  HeaderView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/30/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Darwin
import Foundation
import UIKit

class HeaderView: UIView {
    var xionLogoView:               XIONLogoView = XIONLogoView()
    var connectionStatusView:       ConnectionStatusView = ConnectionStatusView()
    
    private var _xionTitleLabel:    UILabel = UILabel()
    private var _xionJapaneseLabel: UILabel = UILabel()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.blackColor()
        self.addSubview(self.xionLogoView)
        
        _xionTitleLabel.font = UIFont(name: "Orbitron-Medium", size: 16.0)
        _xionTitleLabel.text = "XION arcade system control panel"
        _xionTitleLabel.textColor = UIColor.whiteColor()
        self.addSubview(_xionTitleLabel)
        
        _xionJapaneseLabel.font = UIFont(name: "Orbitron-Medium", size: 12.0)
        _xionJapaneseLabel.text = "ザイーオンゲームセンターのシステム制御プログラム"
        _xionJapaneseLabel.textColor = UIColor.whiteColor()
        self.addSubview(_xionJapaneseLabel)
        
        self.addSubview(self.connectionStatusView)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let hpadding = CGFloat(10.0)
        
        let logoDimensions = rint(bounds.size.height / 1.2)
        let logoFrame = CGRect(
            x: hpadding,
            y: rint(bounds.size.height / 2.0 - logoDimensions / 2.0),
            width: logoDimensions,
            height: logoDimensions
        )
        self.xionLogoView.frame = logoFrame
        
        let titleJPVerticalMargin: CGFloat = 5.0
        let titleLabelSize = _xionTitleLabel.sizeThatFits(bounds.size)
        let jpLabelSize = _xionJapaneseLabel.sizeThatFits(bounds.size)
        let totalLabelsHeight = titleLabelSize.height + titleJPVerticalMargin + jpLabelSize.height
        
        let titleFrame = CGRect(
            x: CGRectGetMaxX(logoFrame) + hpadding * 2.0,
            y: rint(bounds.size.height / 2.0 - totalLabelsHeight / 2.0),
            width: titleLabelSize.width,
            height: titleLabelSize.height
        )
        _xionTitleLabel.frame = titleFrame
        
        let jpTitleFrame = CGRect(
            x: titleFrame.origin.x,
            y: CGRectGetMaxY(titleFrame) + titleJPVerticalMargin,
            width: jpLabelSize.width,
            height: jpLabelSize.height + 2.0
        )
        _xionJapaneseLabel.frame = jpTitleFrame
        
        let connectionStatusDimensions = CGSize(width: rint((1.0 / 8.0) * bounds.size.width), height: bounds.size.height)
        let connectionStatusFrame = CGRect(
            x: bounds.size.width - connectionStatusDimensions.width,
            y: 0.0,
            width: connectionStatusDimensions.width,
            height: connectionStatusDimensions.height
        )
        self.connectionStatusView.frame = connectionStatusFrame
    }
}

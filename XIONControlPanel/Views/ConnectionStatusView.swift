//
//  ConnectionStatusView.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import UIKit

class ConnectionStatusView: UIView
{
    fileprivate var _connectivityStatus: ConnectionStatus = .disconnected
    fileprivate var _japaneseLabel:      UILabel = UILabel()
    fileprivate var _englishLabel:       UILabel = UILabel()
    
    static fileprivate let labelsVMargin: CGFloat = 5.0
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        _japaneseLabel.font = UIFont(name: "Orbitron-Medium", size: 24.0)
        _japaneseLabel.textColor = UIColor.white
        self.addSubview(_japaneseLabel)
        
        _englishLabel.font = UIFont(name: "Orbitron-Medium", size: 16.0)
        _englishLabel.textColor = UIColor.white
        self.addSubview(_englishLabel)
        
        self.connectivityStatus = .disconnected
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("unsupported")
    }
    
    // MARK: Overrides
    
    override func sizeThatFits(_ size: CGSize) -> CGSize
    {
        let labelsVMargin = ConnectionStatusView.labelsVMargin
        let jpLabelSize = _japaneseLabel.sizeThatFits(size)
        let enLabelSize = _englishLabel.sizeThatFits(size)
        let totalLabelsHeight = jpLabelSize.height + labelsVMargin + enLabelSize.height
        let maxLabelsWidth = max(jpLabelSize.width, enLabelSize.width)
        return CGSize(width: maxLabelsWidth, height: totalLabelsHeight)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let labelsVMargin = ConnectionStatusView.labelsVMargin
        let jpLabelSize = _japaneseLabel.sizeThatFits(bounds.size)
        let enLabelSize = _englishLabel.sizeThatFits(bounds.size)
        let totalLabelsHeight = jpLabelSize.height + labelsVMargin + enLabelSize.height
        
        _japaneseLabel.frame = CGRect(
            x: rint(bounds.size.width / 2.0 - jpLabelSize.width / 2.0),
            y: rint(bounds.size.height / 2.0 - totalLabelsHeight / 2.0),
            width: jpLabelSize.width,
            height: jpLabelSize.height
        )
        
        _englishLabel.frame = CGRect(
            x: rint(bounds.size.width / 2.0 - enLabelSize.width / 2.0),
            y: _japaneseLabel.frame.maxY + labelsVMargin,
            width: enLabelSize.width,
            height: enLabelSize.height
        )
    }
    
    // MARK: API
    
    var connectivityStatus: ConnectionStatus
    {
        get
        {
            return _connectivityStatus
        }
        
        set(newStatus)
        {
            _connectivityStatus = newStatus
            
            switch (_connectivityStatus) {
            case .disconnected:
                _japaneseLabel.text = "非直結"
                _japaneseLabel.textColor = UIColor.red
                
                _englishLabel.text = "offline"
                _englishLabel.textColor = UIColor.red
            case .connecting:
                _japaneseLabel.text = "接続中"
                _japaneseLabel.textColor = UIColor.yellow
                
                _englishLabel.text = "connecting..."
                _englishLabel.textColor = UIColor.yellow
            case .connected:
                _japaneseLabel.text = "直結"
                _japaneseLabel.textColor = UIColor.green
                
                _englishLabel.text = "online"
                _englishLabel.textColor = UIColor.green
            case .error:
                _japaneseLabel.text = "過失"
                _japaneseLabel.textColor = UIColor.red
                
                _englishLabel.text = "error"
                _englishLabel.textColor = UIColor.red
            }
            
            self.setNeedsLayout()
        }
    }
}

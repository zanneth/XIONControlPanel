//
//  WemoDevice.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

class WemoDevice: Hashable
{
    enum State
    {
        case off
        case on
    }
    
    enum DeviceType
    {
        case `switch`
    }
    
    var name:   String = ""
    var host:   String = ""
    var model:  String = ""
    var state:  State = .off
    var type:   DeviceType = .switch
    var serial: String = ""
    
    init()
    {}
    
    init(_ dict: NSDictionary)
    {
        if let name = dict["name"] as? NSString {
            self.name = String(name)
        }
        
        if let host = dict["host"] as? NSString {
            self.host = String(host)
        }
        
        if let model = dict["model"] as? NSString {
            self.model = String(model)
        }
        
        if let state = dict["state"] as? NSNumber {
            switch (state.intValue) {
            case 0:
                self.state = .off
            case 1:
                self.state = .on
            default:
                self.state = .off
            }
        }
        
        if let serial = dict["serialnumber"] as? NSString {
            self.serial = String(serial)
        }
    }
    
    var hashValue: Int
    {
        var hash: Int = 0x0
        hash ^= self.name.hash
        hash ^= self.host.hash
        hash ^= self.model.hash
        hash ^= self.state.hashValue
        hash ^= self.type.hashValue
        hash ^= self.serial.hashValue
        
        return hash
    }
}

func ==(lhs: WemoDevice, rhs: WemoDevice) -> Bool
{
    return (lhs.serial == rhs.serial)
}

//
//  WemoDevice.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

struct WemoDevice {
    enum State {
        case Off
        case On
    }
    
    enum Type {
        case Switch
    }
    
    var name:   String = ""
    var host:   String = ""
    var model:  String = ""
    var state:  State = .Off
    var type:   Type = .Switch
    var serial: String = ""
    
    init()
    {}
    
    init(_ responseData: NSData)
    {
        if let dict = (try? NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions())) as? NSDictionary {
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
                switch (state.integerValue) {
                case 0:
                    self.state = .Off
                case 1:
                    self.state = .On
                default:
                    self.state = .Off
                }
            }
            
            if let serial = dict["serialnumber"] as? NSString {
                self.serial = String(serial)
            }
        }
    }
}

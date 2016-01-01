//
//  NSErrorAdditions.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

enum XIONErrorCode: Int {
    case Unknown
    case ConnectionError
}

extension NSError {
    private static let XIONErrorDomain = "com.xionsf.controlpanel"
    
    class func xionError(code: XIONErrorCode) -> NSError
    {
        return self.xionError(code, userInfo: nil)
    }
    
    class func xionError(code: XIONErrorCode, underlying: NSError?) -> NSError
    {
        var userInfo: [NSObject : AnyObject]? = nil
        if (underlying != nil) {
            userInfo = [
                NSUnderlyingErrorKey : underlying!
            ]
        }
        
        return self.xionError(code, userInfo: userInfo)
    }
    
    class func xionError(code: XIONErrorCode, userInfo: [NSObject : AnyObject]?) -> NSError
    {
        return NSError(domain: XIONErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
    
    var xionErrorCode: XIONErrorCode
    {
        return XIONErrorCode(rawValue: self.code)!
    }
}

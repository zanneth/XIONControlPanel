//
//  NSErrorAdditions.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

enum XIONErrorCode: Int
{
    case unknown
    case connectionError
}

struct XIONError : Error
{
    enum ErrorCode
    {
        case unknown
        case connectionError
    }
}

extension NSError
{
    fileprivate static let XIONErrorDomain = "com.xionsf.controlpanel"
    
    class func xionError(_ code: XIONErrorCode) -> NSError
    {
        return self.xionError(code, userInfo: nil)
    }
    
    class func xionError(_ code: XIONErrorCode, underlying: NSError?) -> NSError
    {
        var userInfo: [AnyHashable: Any]? = nil
        if (underlying != nil) {
            userInfo = [
                NSUnderlyingErrorKey : underlying!
            ]
        }
        
        return self.xionError(code, userInfo: userInfo)
    }
    
    class func xionError(_ code: XIONErrorCode, userInfo: [AnyHashable: Any]?) -> NSError
    {
        return NSError(domain: XIONErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
    
    var xionErrorCode: XIONErrorCode
    {
        return XIONErrorCode(rawValue: self.code)!
    }
}

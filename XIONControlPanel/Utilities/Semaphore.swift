//
//  Semaphore.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 1/18/16.
//  Copyright © 2016 XION. All rights reserved.
//

import Foundation

class Semaphore {
    private var _semaphore: dispatch_semaphore_t
    
    init(value: Int)
    {
        _semaphore = dispatch_semaphore_create(value)
    }
    
    func wait()
    {
        self.wait(nil)
    }
    
    func wait(untilDate: NSDate?)
    {
        var time: dispatch_time_t = DISPATCH_TIME_FOREVER
        if (untilDate != nil) {
            time = UInt64(untilDate!.timeIntervalSinceNow) * NSEC_PER_SEC
        }
        
        dispatch_semaphore_wait(_semaphore, time)
    }
    
    func signal()
    {
        dispatch_semaphore_signal(_semaphore)
    }
}

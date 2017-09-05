//
//  Semaphore.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 1/18/16.
//  Copyright © 2016 XION. All rights reserved.
//

import Foundation

class Semaphore
{
    fileprivate var _semaphore: DispatchSemaphore
    
    init(value: Int)
    {
        _semaphore = DispatchSemaphore(value: value)
    }
    
    func wait()
    {
        self.wait(nil)
    }
    
    func wait(_ untilDate: Date?)
    {
        var time: DispatchTime = DispatchTime.distantFuture
        if let untilDate = untilDate {
            time = .now() + .milliseconds(Int(untilDate.timeIntervalSinceNow * 1000))
        }
        
        let result = _semaphore.wait(timeout: time)
        if (result != .success) {
            print("semaphore timed out")
        }
    }
    
    func signal()
    {
        _semaphore.signal()
    }
}

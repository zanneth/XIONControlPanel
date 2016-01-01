//
//  StandardError.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

class StandardErrorOutputStream: OutputStreamType {
    func write(string: String) {
        let stderr = NSFileHandle.fileHandleWithStandardError()
        stderr.writeData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}

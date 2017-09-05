//
//  StandardError.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

class StandardErrorOutputStream: TextOutputStream
{
    func write(_ string: String)
    {
        let stderr = FileHandle.standardError
        stderr.write(string.data(using: String.Encoding.utf8)!)
    }
}

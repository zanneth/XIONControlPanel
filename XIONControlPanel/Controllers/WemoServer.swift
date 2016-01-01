//
//  WemoServer.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

enum ConnectionStatus {
    case Disconnected
    case Connecting
    case Connected
    case Error
}

class WemoServer {
    private(set) var baseURL:   NSURL
    private(set) var connected: Bool = false
    
    private var _urlSession:    NSURLSession
    private var _errorStream:   StandardErrorOutputStream = StandardErrorOutputStream()
    
    init(_ url: NSURL)
    {
        self.baseURL = url
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        _urlSession = NSURLSession(configuration: config)
    }
    
    func connect(completion: (NSError?) -> Void)
    {
        if (!self.connected) {
            let url = self.baseURL.URLByAppendingPathComponent("api/environment")
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            let task = _urlSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                var clientError: NSError? = nil
                
                if (error != nil) {
                    clientError = NSError.xionError(.ConnectionError, underlying: error!)
                    self._logError("Error connecting to server", error: clientError!)
                } else {
                    self.connected = true
                }
                
                completion(clientError)
            }
            task.resume()
        } else {
            completion(nil)
        }
    }
    
    func disconnect(completion: (NSError?) -> Void)
    {
        self.connected = false
        completion(nil)
    }
    
    func fetchDevices(completion: ([WemoDevice], NSError?) -> Void)
    {
        if (self.connected) {
            let url = self.baseURL.URLByAppendingPathComponent("api/environment")
            let task = _urlSession.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                var devices: [WemoDevice] = []
                var clientError: NSError? = nil
                
                if (data != nil) {
                    devices = self._parseDevices(data!)
                } else {
                    clientError = NSError.xionError(.ConnectionError, underlying: error)
                    self._logError("Error fetching devices", error: clientError!)
                }
                
                completion(devices, clientError)
            }
            task.resume()
        } else {
            let err = NSError.xionError(.ConnectionError)
            completion([], err)
        }
    }
    
    func toggleDevice(device: WemoDevice, state: WemoDevice.State, completion: (NSError?) -> Void)
    {
        if (self.connected) {
            let stateArg = (state == .On ? "on" : "off")
            let url = self.baseURL.URLByAppendingPathComponent("api/device/\(device.name)").URLByAppendingRequestParameters(["state" : stateArg])
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            
            let task = _urlSession.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                var clientError: NSError? = nil
                
                if (error != nil) {
                    clientError = NSError.xionError(.ConnectionError, underlying: error)
                    self._logError("Error toggling device \"\(device.name)\"", error: clientError!)
                }
                
                completion(clientError)
            }
            task.resume()
        } else {
            let err = NSError.xionError(.ConnectionError)
            completion(err)
        }
    }
    
    // MARK: Internal
    
    internal func _logError(description: String, error: NSError)
    {
        print("ERROR: \(description) \(error)", toStream: &_errorStream)
    }
    
    internal func _parseDevices(data: NSData) -> [WemoDevice]
    {
        var devices: [WemoDevice] = []
        
        if let responseDict = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary) {
            for responseObj in (responseDict?.allValues)! {
                if let responseDict = responseObj as? NSDictionary {
                    let device = WemoDevice(responseDict)
                    devices.append(device)
                }
            }
        }
        
        return devices
    }
}

//
//  WemoServer.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/31/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Foundation

enum ConnectionStatus
{
    case Disconnected
    case Connecting
    case Connected
    case Error
}

class WemoServer
{
    private(set) var baseURL:    NSURL
    private(set) var connected:  Bool = false
    
    private var _urlSession:     NSURLSession
    private var _errorStream:    StandardErrorOutputStream = StandardErrorOutputStream()
    private var _operationQueue: NSOperationQueue = NSOperationQueue()
    
    init(_ url: NSURL)
    {
        self.baseURL = url
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        _urlSession = NSURLSession(configuration: config)
        
        _operationQueue.maxConcurrentOperationCount = 1
    }
    
    func connect(completion: (NSError?) -> Void)
    {
        if (!self.connected) {
            let op = ConnectOperation(baseURL: self.baseURL, session: _urlSession)
            weak var weakOp = op
            op.completionBlock = {
                guard let strongOp = weakOp else { completion(nil) ; return }
                if (strongOp.error != nil) {
                    self._logError("Error connecting to server", error: strongOp.error!)
                } else {
                    self.connected = true
                }
                
                completion(strongOp.error)
            }
            _operationQueue.addOperation(op)
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
            let op = FetchDevicesOperation(baseURL: self.baseURL, session: _urlSession)
            weak var weakOp = op
            op.completionBlock = {
                guard let strongOp = weakOp else { completion([], nil) ; return }
                if (strongOp.error != nil) {
                    self._logError("Error fetching devices", error: strongOp.error!)
                }
                
                completion(strongOp.devices, strongOp.error)
            }
            _operationQueue.addOperation(op)
        } else {
            let err = NSError.xionError(.ConnectionError)
            completion([], err)
        }
    }
    
    func toggleDevice(device: WemoDevice, state: WemoDevice.State, completion: (NSError?) -> Void)
    {
        if (self.connected) {
            let op = ToggleDeviceOperation(baseURL: self.baseURL, session: _urlSession, device: device, state: state)
            weak var weakOp = op
            op.completionBlock = {
                guard let strongOp = weakOp else { completion(nil) ; return }
                if (strongOp.error != nil) {
                    self._logError("Error toggling device", error: strongOp.error!)
                }
                
                completion(strongOp.error)
            }
            _operationQueue.addOperation(op)
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
}

internal class WemoOperation : NSOperation
{
    var baseURL:   NSURL
    var session:   NSURLSession
    
    internal(set) var error: NSError?
    
    init(baseURL: NSURL, session: NSURLSession)
    {
        self.baseURL = baseURL
        self.session = session
    }
}

internal class ConnectOperation : WemoOperation
{
    override func main()
    {
        let semaphore = Semaphore(value: 0)
        let url = self.baseURL.URLByAppendingPathComponent("api/environment")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let task = self.session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error != nil) {
                self.error = NSError.xionError(.ConnectionError, underlying: error!)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
}

internal class FetchDevicesOperation : WemoOperation
{
    internal(set) var devices: [WemoDevice] = []
    
    override func main()
    {
        let semaphore = Semaphore(value: 0)
        let url = self.baseURL.URLByAppendingPathComponent("api/environment")
        let task = self.session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (data != nil) {
                self.devices = self._parseDevices(data!)
            } else {
                self.error = NSError.xionError(.ConnectionError, underlying: error)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
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

internal class ToggleDeviceOperation : WemoOperation
{
    var device: WemoDevice
    var state:  WemoDevice.State
    
    init(baseURL: NSURL, session: NSURLSession, device: WemoDevice, state: WemoDevice.State)
    {
        self.device = device
        self.state = state
        super.init(baseURL: baseURL, session: session)
    }
    
    override func main()
    {
        let semaphore = Semaphore(value: 0)
        let stateArg = (self.state == .On ? "on" : "off")
        let url = self.baseURL.URLByAppendingPathComponent("api/device/\(self.device.name)").URLByAppendingRequestParameters(["state" : stateArg])
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        
        let task = self.session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (error != nil) {
                self.error = NSError.xionError(.ConnectionError, underlying: error)
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
}

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
    case disconnected
    case connecting
    case connected
    case error
}

enum ConnectionError : Error
{
    case unknown
    case serverUnavailable
}

class WemoServer
{
    fileprivate(set) var baseURL:    URL
    fileprivate(set) var connected:  Bool = false
    
    fileprivate var _urlSession:     URLSession
    fileprivate var _errorStream:    StandardErrorOutputStream = StandardErrorOutputStream()
    fileprivate var _operationQueue: OperationQueue = OperationQueue()
    
    init(_ url: URL)
    {
        self.baseURL = url
        
        let config = URLSessionConfiguration.default
        _urlSession = URLSession(configuration: config)
        
        _operationQueue.maxConcurrentOperationCount = 1
    }
    
    func connect(_ completion: @escaping (Error?) -> Void)
    {
        if (!self.connected) {
            let op = ConnectOperation(baseURL: self.baseURL, session: _urlSession)
            weak var weakOp = op
            op.completionBlock = {
                guard let strongOp = weakOp else { completion(nil) ; return }
                if let error = strongOp.error {
                    self._logError("Error connecting to server", error: error)
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
    
    func disconnect(_ completion: (Error?) -> Void)
    {
        self.connected = false
        completion(nil)
    }
    
    func fetchDevices(_ completion: @escaping ([WemoDevice], Error?) -> Void)
    {
        if (self.connected) {
            let op = FetchDevicesOperation(baseURL: self.baseURL, session: _urlSession)
            weak var weakOp = op
            op.completionBlock = {
                guard let strongOp = weakOp else { completion([], nil) ; return }
                if let error = strongOp.error {
                    self._logError("Error fetching devices", error: error)
                }
                
                completion(strongOp.devices, strongOp.error)
            }
            _operationQueue.addOperation(op)
        } else {
            let err = ConnectionError.serverUnavailable
            completion([], err)
        }
    }
    
    func toggleDevice(_ device: WemoDevice, state: WemoDevice.State, completion: @escaping (Error?) -> Void)
    {
        if (self.connected) {
            let op = ToggleDeviceOperation(baseURL: self.baseURL, session: _urlSession, device: device, state: state)
            weak var weakOp = op
            op.completionBlock = {
                guard let strongOp = weakOp else { completion(nil) ; return }
                if let error = strongOp.error {
                    self._logError("Error toggling device", error: error)
                }
                
                completion(strongOp.error)
            }
            _operationQueue.addOperation(op)
        } else {
            let err = ConnectionError.serverUnavailable
            completion(err)
        }
    }
    
    // MARK: Internal
    
    internal func _logError(_ description: String, error: Error)
    {
        print("ERROR: \(description) \(error)", to: &_errorStream)
    }
}

internal class WemoOperation : Operation
{
    var baseURL:   URL
    var session:   URLSession
    
    internal(set) var error: Error?
    
    init(baseURL: URL, session: URLSession)
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
        let url = self.baseURL.appendingPathComponent("api/environment")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            self.error = error
            semaphore.signal()
        }) 
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
        let url = self.baseURL.appendingPathComponent("api/environment")
        let task = self.session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (data != nil) {
                self.devices = self._parseDevices(data!)
            } else {
                self.error = error
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    internal func _parseDevices(_ data: Data) -> [WemoDevice]
    {
        var devices: [WemoDevice] = []
        
        if let responseDict = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? NSDictionary) {
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
    
    init(baseURL: URL, session: URLSession, device: WemoDevice, state: WemoDevice.State)
    {
        self.device = device
        self.state = state
        super.init(baseURL: baseURL, session: session)
    }
    
    override func main()
    {
        let semaphore = Semaphore(value: 0)
        let stateArg = (self.state == .on ? "on" : "off")
        let url = self.baseURL.appendingPathComponent("api/device/\(self.device.name)").URLByAppendingRequestParameters(["state" : stateArg])
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let task = self.session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            self.error = error
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
}

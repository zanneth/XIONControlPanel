//
//  VisualizationViewController.swift
//  XIONControlPanel
//
//  Created by Charles Magahern on 12/29/15.
//  Copyright © 2015 XION. All rights reserved.
//

import Darwin
import Foundation
import GLKit
import SceneKit
import UIKit

let π = CGFloat(M_PI)

class VisualizationViewController: UIViewController {
    private var _scene:             SCNScene = SCNScene()
    private var _sceneView:         SCNView?
    private var _cameraNode:        SCNNode = SCNNode()
    private var _lightNode:         SCNNode = SCNNode()
    private var _cubletsNode:       SCNNode = SCNNode()
    private var _cublets:           [SCNNode] = []
    private var _percentActivated:  Float = 0.0
    
    static private let cubletsDimensions = 5
    static private let cubletsSize = 1.0
    static private let cubletsSpacing = 2.0
    static private let rotationAnimationKey = "RotationAnimation"
    
    // MARK: Overrides
    
    override func loadView()
    {
        let opts = [SCNPreferredRenderingAPIKey : SCNRenderingAPI.OpenGLES2.rawValue]
        let view = SCNView(frame: UIScreen.mainScreen().bounds, options: opts)
        view.backgroundColor = UIColor.blackColor()
        view.scene = _scene
        view.allowsCameraControl = false
        
        _sceneView = view
        self.view = view
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        _setupCamera()
        _setupLights()
        _setupModel()
        _setupAnimation()
        _setupEffects()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        _sceneView?.play(nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        _sceneView?.stop(nil)
    }
    
    // MARK: API
    
    var connectionStatus: ConnectionStatus = .Disconnected
    {
        didSet
        {
            switch (self.connectionStatus) {
            case .Disconnected, .Connecting, .Error:
                _cubletsNode.paused = true
                _lightNode.light?.color = UIColor(white: 0.3, alpha: 1.0)
            case .Connected:
                _cubletsNode.paused = false
                _lightNode.light?.color = UIColor.whiteColor()
            }
        }
    }
    
    var percentActivated: Float
    {
        get
        {
            return _percentActivated
        }
        
        set(percentage)
        {
            self.setPercentActivated(percentage, animated: false)
        }
    }
    
    func setPercentActivated(percentage: Float, animated: Bool)
    {
        let cubletsCount = _cublets.count
        let cubletsToActivate = UInt(percentage * Float(cubletsCount))
        var shuffledCublets = _cublets
        var cubletsActivated: UInt = 0
        
        for i in 0 ..< cubletsCount {
            let rnd = Int(arc4random_uniform(UInt32(cubletsCount)))
            let tmp = shuffledCublets[rnd]
            shuffledCublets[rnd] = shuffledCublets[i]
            shuffledCublets[i] = tmp
        }
        
        for cublet in shuffledCublets {
            _setCubletActivated(cublet, activated: (cubletsActivated < cubletsToActivate))
            ++cubletsActivated
        }
        
        if (animated) {
            let rx = Float(arc4random()) / Float(UInt32.max)
            let ry = Float(arc4random()) / Float(UInt32.max)
            let rz = Float(arc4random()) / Float(UInt32.max)
            let rotAxis = SCNVector3Make(rx, ry, rz)
            let rotCoeff = CGFloat(arc4random() % 2 == 0 ? -1.0 : 1.0)
            let rotAngle = CGFloat(rotCoeff * π / 4.0)
            
            let rotAction = SCNAction.rotateByAngle(rotAngle, aroundAxis: rotAxis, duration: 0.8)
            rotAction.timingMode = .Linear
            rotAction.timingFunction = { (t: Float) -> Float in
                return min(((log10(4.0 * (t + 0.03)) + 1.0) / 1.5), 1.0)
            }
            
            // modify the existing rotation animation as well, so that we have a
            // smooth transition
            let longTermAnimKey = VisualizationViewController.rotationAnimationKey
            let newLongTermRotAction = _createLongTermRotationAnimation((rotCoeff * 2.0 * π), rotAxis)
            _cubletsNode.removeActionForKey(longTermAnimKey)
            
            let actionSeq = SCNAction.sequence([rotAction, newLongTermRotAction])
            _cubletsNode.runAction(actionSeq, forKey: longTermAnimKey)
        }
        
        _setAnimationSpeed(CGFloat(1.0 + (percentage * 2.0)))
        
        _percentActivated = percentage
    }
    
    // MARK: Internal
    
    internal func _setupCamera()
    {
        let camera = SCNCamera()
        
        _cameraNode.camera = camera
        _cameraNode.position = SCNVector3Make(0.0, 0.0, 30.0)
        _scene.rootNode.addChildNode(_cameraNode)
        
        let centerNode = SCNNode()
        centerNode.position = SCNVector3Zero
        _scene.rootNode.addChildNode(centerNode)
        
        let constraint = SCNLookAtConstraint(target: centerNode)
        _cameraNode.constraints = [constraint]
    }
    
    internal func _setupLights()
    {
        let light = SCNLight()
        light.type = SCNLightTypeOmni
        light.color = UIColor.whiteColor()
        
        _lightNode = SCNNode()
        _lightNode.light = light
        _lightNode.position = _cameraNode.position
        
        _scene.rootNode.addChildNode(_lightNode)
    }
    
    internal func _setupModel()
    {
        _cublets.removeAll()
        
        let sz = Float(VisualizationViewController.cubletsSize)
        let dim = VisualizationViewController.cubletsDimensions
        let dimf = Float(dim)
        let spacing = Float(VisualizationViewController.cubletsSpacing)
        let volume = (dimf * sz) + ((dimf - 1.0) * spacing)
        let orig = -volume / 2.0
        
        // setup material and geometry. each node needs its own material for the activation effect.
        let geom = SCNBox(width: CGFloat(sz), height: CGFloat(sz), length: CGFloat(sz), chamferRadius: 0.0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.whiteColor()
        material.transparency = 0.75
        
        // generate nodes for each cublet
        for var xi = 0; xi < dim; ++xi {
            let x = orig + Float(xi) * (sz + spacing)
            
            for var yi = 0; yi < dim; ++yi {
                let y = orig + Float(yi) * (sz + spacing)
                
                for var zi = 0; zi < dim; ++zi {
                    let z = orig + Float(zi) * (sz + spacing)
                    
                    let nodeGeom = geom.copy() as! SCNGeometry
                    nodeGeom.firstMaterial = material.copy() as? SCNMaterial
                    
                    let node = SCNNode(geometry: nodeGeom)
                    node.position = SCNVector3Make(x, y, z)
                    _cubletsNode.addChildNode(node)
                    _cublets.append(node)
                }
            }
        }
        
        _cubletsNode.position = SCNVector3Zero
        _scene.rootNode.addChildNode(_cubletsNode)
    }
    
    internal func _setupAnimation()
    {
        let rotAngle = 2.0 * π
        let rotAxis = SCNVector3Make(0.25, 1.75, 1.0)
        let rotationAction = _createLongTermRotationAnimation(rotAngle, rotAxis)
        _cubletsNode.runAction(rotationAction, forKey: VisualizationViewController.rotationAnimationKey)
    }
    
    internal func _setupEffects()
    {
        let techniqueURL = NSBundle.mainBundle().URLForResource("CubletsTechnique", withExtension: "plist")
        let techniqueDict = NSDictionary(contentsOfURL: techniqueURL!) as! [String : AnyObject]
        let technique = SCNTechnique(dictionary: techniqueDict)
        
        _sceneView?.technique = technique
    }
    
    internal func _setCubletActivated(cublet: SCNNode, activated: Bool)
    {
        let material = cublet.geometry?.firstMaterial
        material?.diffuse.contents = (activated ? UIColor.redColor() : UIColor.whiteColor())
    }
    
    internal func _setAnimationSpeed(speed: CGFloat)
    {
        let key = VisualizationViewController.rotationAnimationKey
        let action = _cubletsNode.actionForKey(key)
        _cubletsNode.removeActionForKey(key)
        
        action?.speed = speed
        _cubletsNode.runAction(action!, forKey: key)
    }
    
    internal func _createLongTermRotationAnimation(rotAngle: CGFloat, _ rotAxis: SCNVector3) -> SCNAction
    {
        return SCNAction.repeatActionForever(SCNAction.rotateByAngle(rotAngle, aroundAxis: rotAxis, duration: 40.0))
    }
}

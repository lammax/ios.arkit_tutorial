//
//  VehicleViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 26/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion

class VehicleViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!

    let configuration = ARWorldTrackingConfiguration()
    let motionManager = CMMotionManager()
    let speed: Int = 15
    
    private var vehicle: SCNPhysicsVehicle?
    private var orientation: CGFloat = 0.0
    private var touched: Int = 0
    private var direction: Int = 0
    private var accelerationValues = [UIAccelerationValue(0), UIAccelerationValue(0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAR()
        self.setUpAccelerometer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    func setupAR() {
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.automaticallyUpdatesLighting = true
        self.sceneView.delegate = self
        
        self.configuration.isLightEstimationEnabled = true
        self.configuration.planeDetection = [.vertical, .horizontal]
        
        self.sceneView.session.run(configuration)
    }
    
    func createConcrete(anchor: ARPlaneAnchor) -> SCNNode {
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degrees2radians, 0, 0)
        
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        
        return concreteNode
    }
    
    @IBAction func addVehicleButtonPress(_ sender: UIButton) {
        guard let pov = sceneView.pointOfView else { return }
        let transform = pov.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentCameraPosition = orientation + location
        
        let scene = SCNScene(named: "art.scnassets/Vehicle/Car.scn")
        let carNode = (scene?.rootNode.childNode(withName: "car", recursively: false))!
        carNode.name = "car"
        carNode.position = currentCameraPosition
        
        let frontLeftWheel = carNode.childNode(withName: "frontLeftParent", recursively: false)!
        let frontRightWheel = carNode.childNode(withName: "frontRightParent", recursively: false)!
        let rearLeftWheel = carNode.childNode(withName: "rearLeftParent", recursively: false)!
        let rearRightWheel = carNode.childNode(withName: "rearRightParent", recursively: false)!

        let v_frontLeftWheel = SCNPhysicsVehicleWheel(node: frontLeftWheel)
        let v_frontRightWheel = SCNPhysicsVehicleWheel(node: frontRightWheel)
        let v_rearLeftWheel = SCNPhysicsVehicleWheel(node: rearLeftWheel)
        let v_rearRightWheel = SCNPhysicsVehicleWheel(node: rearRightWheel)

        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: carNode, options: [.keepAsCompound: true] ))
        body.mass = 3
        carNode.physicsBody = body
        
        self.vehicle = SCNPhysicsVehicle(chassisBody: carNode.physicsBody!, wheels: [v_rearLeftWheel, v_rearRightWheel, v_frontLeftWheel, v_frontRightWheel])
        
        self.sceneView.scene.physicsWorld.addBehavior(self.vehicle!)
        self.sceneView.scene.rootNode.addChildNode(carNode)
    }
    
    @IBAction func resetButtonClick(_ sender: UIButton) {
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
            if existingNode.name == "car" {
                existingNode.removeFromParentNode()
            }
        }
        
    }
    
    func setUpAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1/60
            motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let accData = accelerometerData {
                    self.accelerometerDidChange(acceleration: accData.acceleration)
                }
            }
            
        } else {
            print("Accelerometer is not available!")
        }
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration) {
        
        accelerationValues[0] = filtered(currentAcceleration: accelerationValues[0], updatedAcceleration: acceleration.x)
        accelerationValues[1] = filtered(currentAcceleration: accelerationValues[1], updatedAcceleration: acceleration.y)
        
        let vPos = CGFloat(accelerationValues[0] > 0 ? -1 : 1)
        self.orientation = vPos * CGFloat(accelerationValues[1])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {
            return
        }
        self.touched += 1
        print(self.touched)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touched = 0
    }
    
    func filtered(currentAcceleration: Double, updatedAcceleration: Double) -> Double { //for smoother moving
        let kFilteringFactor = 0.5
        return updatedAcceleration * kFilteringFactor + currentAcceleration * (1 - kFilteringFactor)
    }
    
}

extension VehicleViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let concreteNode = createConcrete(anchor: planeAnchor)
        
        node.addChildNode(concreteNode)
        
        print("Found plane: \(planeAnchor)")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        node.addChildNode(createConcrete(anchor: planeAnchor))
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        var brakingForce: CGFloat = 0
        switch self.touched {
        case 0:
            self.direction = 0
        case 1:
            self.direction = 1
        case 2:
            self.direction = -1
        case 3:
            brakingForce = 100
        default:
            print("We doesn't support \(self.touched) touches for now")
        }
        let engineForce: CGFloat = CGFloat(self.speed * self.direction)
        self.vehicle?.setSteeringAngle(-self.orientation, forWheelAt: 2)
        self.vehicle?.setSteeringAngle(-self.orientation, forWheelAt: 3)
        self.vehicle?.applyEngineForce(engineForce, forWheelAt: 0)
        self.vehicle?.applyEngineForce(engineForce, forWheelAt: 1)
        self.vehicle?.applyBrakingForce(brakingForce, forWheelAt: 0)
        self.vehicle?.applyBrakingForce(brakingForce, forWheelAt: 1)
    }
    
}

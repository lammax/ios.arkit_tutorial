//
//  1_NodeViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 04.10.2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class NodeViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    @IBAction func reset(_ sender: UIButton) {
        restartSession()
    }
    
    @IBAction func add(_ sender:  UIButton) {
        let spehereNode = SCNNode()
        addSphere(to: spehereNode)
        spehereNode.geometry?.firstMaterial?.specular.contents = UIColor.white // white light
        spehereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        spehereNode.position = SCNVector3(0.0, 0.5, 0.0)

        
        let node = SCNNode()
        addBezierPath(to: node)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white // white light
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        let x = randomNumbers(firstNum: -0.3, secondNum: 0.3)
        let y = randomNumbers(firstNum: -0.3, secondNum: 0.3)
        let z = randomNumbers(firstNum: -0.3, secondNum: 0.3)
        node.position = SCNVector3(x, -0.1, -0.4)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        node.addChildNode(spehereNode)
        
        node.eulerAngles = SCNVector3(90.degrees2radians, 0, 0)
    }
    
    private func addBezierPath(to node: SCNNode) {
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0.0, y: 0.2))
        path.addLine(to: CGPoint(x: 0.1, y: 0.3))
        path.addLine(to: CGPoint(x: 0.2, y: 0.2))
        path.addLine(to: CGPoint(x: 0.2, y: 0.0))
        path.addLine(to: CGPoint(x: 0.0, y: 0.0))
        let shape = SCNShape(path: path, extrusionDepth: 0.2)
        node.geometry = shape
    }
    
    private func addPyramid(to node: SCNNode) {
        node.geometry = SCNPyramid(width: 0.2, height: 0.3, length: 0.2)
    }
    
    private func addPlane(to node: SCNNode) {
        node.geometry = SCNPlane(width: 0.3, height: 0.3)
    }
    
    private func addCapsule(to node: SCNNode) {
        node.geometry = SCNCapsule(capRadius:  0.1, height: 0.3)
    }
    
    private func addTorus(to node: SCNNode) {
        node.geometry = SCNTorus(ringRadius: 0.3, pipeRadius: 0.1)
    }
    
    private func addSphere(to node: SCNNode) {
        node.geometry = SCNSphere(radius: 0.1)
    }
    
    private func addTube(to node: SCNNode) {
        node.geometry = SCNTube(innerRadius: 0.2, outerRadius: 0.3, height: 0.5)
    }
    
    private func addCylinder(to node: SCNNode) {
        node.geometry = SCNCylinder(radius: 0.1, height: 0.3)
    }
    
    private func addCone(to node: SCNNode) {
        node.geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.3, height: 0.5)
    }
    
    private func addBox(to node: SCNNode) {
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
    }
    
    func restartSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(
            configuration,
            options: [.resetTracking, .removeExistingAnchors]
        )
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random())
            / CGFloat(UINT32_MAX)
            * abs(firstNum - secondNum)
            + min(firstNum, secondNum)
    }
    
}

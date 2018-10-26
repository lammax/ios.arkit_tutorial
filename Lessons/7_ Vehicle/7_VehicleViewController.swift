//
//  VehicleViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 26/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class VehicleViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!

    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.automaticallyUpdatesLighting = true
        self.sceneView.delegate = self
        
        self.configuration.isLightEstimationEnabled = true
        self.configuration.planeDetection = [.vertical, .horizontal]
        
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    func createConcrete(anchor: ARPlaneAnchor) -> SCNNode {
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "concrete")
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degrees2radians, 0, 0)
        return concreteNode
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
}

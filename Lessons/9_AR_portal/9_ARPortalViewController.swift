//
//  ARPortal.swift
//  ARKit_tutorial
//
//  Created by Mac on 07/01/2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit
import ARKit

class ARPortalViewController: UIViewController {
    
    //MARK: constants
    let configuration = ARWorldTrackingConfiguration()
    
    //MARK: outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var planeDetectedLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAR()
        self.setupGestureRecognizers()
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
    
    func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneViewTappedOn = sender.view as? ARSCNView else { return }
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
           self.addPortal(hitTestResult: hitTest.first!)
        }
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "art.scnassets/Portal/Portal.scn")
        let portalNode = portalScene?.rootNode.childNode(withName: "Portal", recursively: false)
        let transform = hitTestResult.worldTransform
        portalNode?.position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        self.sceneView.scene.rootNode.addChildNode(portalNode!)
    }
    
}

extension ARPortalViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            self.planeDetectedLabel.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetectedLabel.isHidden = true
        }
        
        print("Found plane: \(planeAnchor)")
    }

}

//
//  ThreeDModelsHitTesting.swift
//  ARKit_tutorial
//
//  Created by Mac on 19/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class ModelsHitTestingViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
        self.addTapGesture(view: self.sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    @IBAction func clickPlayButton(_ sender: UIButton) {
        self.addNode()
    }
    
    @IBAction func clickResetButton(_ sender: UIButton) {
    }
    
    func addTapGesture(view: ARSCNView) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {

        let sceneViewTappedOn = sender.view as! SCNView
        
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        if hitTest.isEmpty {
            print("You didn't touch anything at all")
        } else {
            let node = hitTest.first!.node
            self.animateNode(node: node)
        }
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")!
        let jellyFishNode = jellyFishScene.rootNode.childNode(withName: "Jellyfish", recursively: false)
        if let node = jellyFishNode {
            node.position = SCNVector3(0, 0, -1)
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(0, 0, node.presentation.position.z - 1)
        node.addAnimation(spin, forKey: "position")
        
    }
    
    
}

extension ModelsHitTestingViewController: ARSCNViewDelegate {
    
}

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
    
    @objc func handleTap() {
        print("Scene view tapped")
    }
    
    func addNode() {
        
        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
        
        node.position = SCNVector3(0, 0, -1)
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    
}

extension ModelsHitTestingViewController: ARSCNViewDelegate {
    
}

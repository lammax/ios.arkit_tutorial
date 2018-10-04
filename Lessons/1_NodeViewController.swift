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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func reset(_ sender: UIButton) {
        restartSession()
    }
    
    @IBAction func add(_ sender: UIButton) {
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        node.position = SCNVector3(0.1, 0.1, 0.1)
        self.sceneView.scene.rootNode.addChildNode(node)
        
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
    
}

//
//  TextureSurfaceViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 05.10.2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class TextureSurfaceViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addEarthNode()
    }
    
    private func addEarthNode() {
        let earthNode = SCNNode(geometry: SCNSphere(radius: 0.2))
        earthNode.geometry?.firstMaterial?.specular.contents = UIImage(named: "Earth_specular")
        earthNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Earth_day")
        earthNode.geometry?.firstMaterial?.emission.contents = UIImage(named: "Earth_emission")
        earthNode.geometry?.firstMaterial?.normal.contents = UIImage(named: "Earth_normal")
        earthNode.position = SCNVector3(0, 0, -1)
        self.sceneView.scene.rootNode.addChildNode(earthNode)
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 24)
        let forever = SCNAction.repeatForever(rotation)
        earthNode.runAction(forever)
    }
    
    

}

extension TextureSurfaceViewController: ARSCNViewDelegate {
    
    
    
}

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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
}

extension ModelsHitTestingViewController: ARSCNViewDelegate {
    
}

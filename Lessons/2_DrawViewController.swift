//
//  DrawViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 05.10.2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class DrawViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var colorSliderView: UIView!
    
    let configuration = ARWorldTrackingConfiguration()
    let pointer: SCNNode = SCNNode(geometry: SCNSphere(radius: 0.01))
    
    private var currentDrawColor: UIColor = UIColor.black

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        
        self.sceneView.scene.rootNode.addChildNode(self.pointer)
        
        self.colorSliderInit()

    }

    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    func colorSliderInit() {
        let colorSliderframe = CGRect(origin: .zero, size: colorSliderView.frame.size)
        let colorSlider = ColorPickerSlider(frame: colorSliderframe)
        colorSlider.didChangeColor = { color in
            if let chosenLinkColor = color {
                self.currentDrawColor = chosenLinkColor
                DispatchQueue.main.async {
                    self.pointer.geometry?.firstMaterial?.diffuse.contents = self.currentDrawColor
                }
            }
        }
        colorSlider.colorPickerSliderHeight = 5.0
        self.colorSliderView.addSubview(colorSlider)
    }

}

extension DrawViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = self.sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let frontOfCamera = orientation + location
        
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = frontOfCamera
                sphereNode.geometry?.firstMaterial?.diffuse.contents = self.currentDrawColor
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
            } else {
                self.pointer.position = frontOfCamera
            }
        }
        
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

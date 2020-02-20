//
//  ARMeasuringViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 26/12/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class ARMeasuringViewController: UIViewController {
    
    //MARK: constants
    let configuration = ARWorldTrackingConfiguration()
    
    //MARK: vars
    var startingPosition: SCNNode?
    
    
    //MARK: outlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    
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
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        let camera = currentFrame.camera
        let transform = camera.transform
        self.addCenterNode(transform: transform)
    }
    
    func addCenterNode(transform: simd_float4x4) {
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        sphere.simdTransform = moveMatrix(transform: transform)

        self.finishMeasuring(finishNode: sphere)
        
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPosition = sphere
        
    }
    
    func finishMeasuring(finishNode: SCNNode) {
        if self.startingPosition != nil {
            self.addLineBetween(start: self.startingPosition!.position, end: finishNode.position)
            self.sceneView.scene.rootNode.addChildNode(finishNode)
            self.startingPosition = nil
            return
        }
    }
    
    func addLineBetween(start: SCNVector3, end: SCNVector3) {
        let lineGeometry = SCNGeometry.lineFrom(vector: start, toVector: end)
        let lineNode = SCNNode(geometry: lineGeometry)
        
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    func moveMatrix(transform: simd_float4x4) -> simd_float4x4 {
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        return simd_mul(transform, translationMatrix)
    }
    
    func distance(start: SCNVector3, end: SCNVector3) -> Float {
        return sqrt(
            powf(end.x - start.x, 2.0) +
            powf(end.y - start.y, 2.0) +
            powf(end.z - start.z, 2.0)
        )
    }
    
}

extension ARMeasuringViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = self.startingPosition else { return }
        guard let pointOfView =  self.sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f m", xDistance)
            self.yLabel.text = String(format: "%.2f m", yDistance)
            self.zLabel.text = String(format: "%.2f m", zDistance)
            self.distanceLabel.text = String(format: "%.2f m", self.distance(start: startingPosition.position, end: location))
        }

    }
    
}

extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let lineGeometry = SCNGeometry(sources: [source], elements: [element])
        lineGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
        
        return lineGeometry
    }
}

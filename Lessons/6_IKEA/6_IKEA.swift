//
//  IKEA.swift
//  ARKit_tutorial
//
//  Created by Mac on 26/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit

class IKEAViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var labelPlaneDetected: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()
    let itemArray: [String] = ["cup", "vase", "boxing", "table"]
    private var currentItem: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true

        self.sceneView.delegate = self
        
        //self.configuration.isLightEstimationEnabled = true
        self.configuration.planeDetection = [.vertical, .horizontal]
        
        self.registerGestureRecognizers()
        
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.sceneView.session.pause()
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(sender: UIPinchGestureRecognizer) {
        let sceneViewPinchOn = sender.view as! ARSCNView
        let holdCoordinates = sender.location(in: sceneViewPinchOn)
        let hitTest = sceneViewPinchOn.hitTest(holdCoordinates)
        if !hitTest.isEmpty {
            
            let result = hitTest.first!
            let node = result.node
            
            if sender.state == .began {
                let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotateAction)
                node.runAction(forever)
            } else if sender.state == .ended {
                node.removeAllActions()
            }
        }

        
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        let sceneViewPinchOn = sender.view as! ARSCNView
        let pinchCoordinates = sender.location(in: sceneViewPinchOn)
        let hitTest = sceneViewPinchOn.hitTest(pinchCoordinates)
        if !hitTest.isEmpty {
            let result = hitTest.first!
            let node = result.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! ARSCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates, types: .existingPlaneUsingExtent)
        if !hitTest.isEmpty {
            self.addItem(at:  hitTest.first!)
        }
    }

    func addItem(at htResult: ARHitTestResult) {
        
        if let item = self.currentItem {
            let scene = SCNScene(named: "art.scnassets/IKEA/\(item).scn")
            let node = scene?.rootNode.childNode(withName: item, recursively: false)
            let transform = htResult.worldTransform
            let thirdColumn = transform.columns.3
            node?.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            if self.currentItem == "table" {
                node?.centerPivot()
            }
            self.sceneView.scene.rootNode.addChildNode(node!)
        }
        
    }

}

extension IKEAViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        DispatchQueue.main.async {
            self.labelPlaneDetected.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.labelPlaneDetected.isHidden = true
        }
        
        print("Found plane: \(planeAnchor)")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        /*node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }*/
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        /*node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }*/
        
    }
}

extension IKEAViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCustomCell
        cell.collectionCellLabel.text = self.itemArray[indexPath.row]
        return cell
    }
    
}

extension IKEAViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.green
        self.currentItem = self.itemArray[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(hex: "FF9300")
    }
    
}

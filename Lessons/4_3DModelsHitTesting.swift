//
//  ThreeDModelsHitTesting.swift
//  ARKit_tutorial
//
//  Created by Mac on 19/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import UIKit
import ARKit
import Each

class ModelsHitTestingViewController: UIViewController {
    
    private var timer = Each(1).seconds
    private var countdown = 0
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    
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
        self.setTimer()
        self.addNode()
        self.playButton.isEnabled = false
        self.restoreTimer()
    }
    
    @IBAction func clickResetButton(_ sender: UIButton) {
        self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
            existingNode.removeFromParentNode()
        }
        self.playButton.isEnabled = true
        self.timer.stop()
        self.restoreTimer()
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
            let nodes = hitTest.filter { (htRes) -> Bool in
                return htRes.node.name == "Jellyfish"
            }
            if !nodes.isEmpty && self.countdown > 0 {
                let node = nodes.first!.node
                if node.animationKeys.isEmpty {
                    SCNTransaction.begin()
                    self.animateNode(node: node)
                    SCNTransaction.completionBlock = {
                        node.removeFromParentNode()
                        self.addNode()
                        self.restoreTimer()
                    }
                    SCNTransaction.commit()
                }
            }
        }
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")!
        let jellyFishNode = jellyFishScene.rootNode.childNode(withName: "Jellyfish", recursively: false)
        if let node = jellyFishNode {
            node.position = SCNVector3(randomNumber(-1, 1) , randomNumber(-1, 1), randomNumber(-1, 1))
            node.name = "Jellyfish"
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func animateNode(node: SCNNode) {
        let spin = CABasicAnimation(keyPath: "position")
        let position = node.presentation.position
        spin.fromValue = position
        spin.toValue = SCNVector3(position.x - 0.1, position.y - 0.1, position.z - 0.1)
        spin.autoreverses = true
        spin.duration = 0.07
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
        
    }
    
    func randomNumber(_ firstNum: CGFloat, _ secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random())
            / CGFloat(UINT32_MAX)
            * abs(firstNum - secondNum)
            + min(firstNum, secondNum)
    }
    
    func setTimer() {
        self.timer.perform { () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            if self.countdown == 0 {
                self.timerLabel.text = "You loose =("
                return .stop
            } else {
                return .continue
            }
        }
    }
    
    func restoreTimer() {
        self.countdown = 10
        self.timerLabel.text = String(self.countdown)
    }
    
    
}

extension ModelsHitTestingViewController: ARSCNViewDelegate {
    
}

//
//  TextureSurfaceViewController.swift
//  ARKit_tutorial
//
//  Created by Mac on 05.10.2018.
//  Copyright © 2018 Lammax. All rights reserved.
// https://www.solarsystemscope.com/textures/

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
        let earthNode = makeEarthNode()
        earthNode.addChildNode(makeRotatingNode(node: makeEarthMoonNode(), duration: 3, baseposition: SCNVector3(0, 0, 0)))

        let venusNode = makeVenusNode()
        venusNode.addChildNode(makeRotatingNode(node: makeVenusMoonNode(), duration: 5, baseposition: SCNVector3(0, 0, 0)))

        self.sceneView.scene.rootNode.addChildNode(makeRotatingNode(node: earthNode, duration: 24, baseposition: SCNVector3(0, 0, -1)))
        self.sceneView.scene.rootNode.addChildNode(makeRotatingNode(node: venusNode, duration: 14, baseposition: SCNVector3(0, 0, -1)))
        self.sceneView.scene.rootNode.addChildNode(makeSunNode())

    }
    
    private func makeRotatingNode(node: SCNNode, duration: Double, baseposition: SCNVector3) -> SCNNode {
        let baseNode = makeBaseNode(baseposition: baseposition)
        addActionForever(
            node: baseNode,
            action: SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: duration)
        )
        baseNode.addChildNode(node)
        
        return baseNode
    }

    private func addActionForever(node: SCNNode, action: SCNAction) {
        let forever = SCNAction.repeatForever(action)
        node.runAction(forever)
    }
    
    private func makeBaseNode(baseposition: SCNVector3) -> SCNNode {
        return makePlanet(position: baseposition)
    }
    
    private func makeSunNode() -> SCNNode {
        let sunNode = makePlanet(geometry: SCNSphere(radius: 0.35), diffuse: "Sun_diffuse", position: SCNVector3(0, 0, -1))
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 25.38)
        let forever = SCNAction.repeatForever(rotation)
        sunNode.runAction(forever)

        return sunNode
    }
    
    private func makeVenusNode() -> SCNNode {
        let venusNode = makePlanet(geometry: SCNSphere(radius: 0.1), diffuse: "Venus_diffuse", emission: "Venus_emission", position: SCNVector3(0.7, 0, 0))
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 243*24)
        let forever = SCNAction.repeatForever(rotation)
        venusNode.runAction(forever)
        
        return venusNode
    }

    private func makeEarthNode() -> SCNNode {
        let earthNode = makePlanet(geometry: SCNSphere(radius: 0.2), diffuse: "Earth_day", specular: "Earth_specular", emission: "Earth_emission", normal: "Earth_normal", position: SCNVector3(1.2, 0, 0))
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 24)
        let forever = SCNAction.repeatForever(rotation)
        earthNode.runAction(forever)

        return earthNode
    }
    
    private func makeEarthMoonNode() -> SCNNode {
        let moonNode = makePlanet(geometry: SCNSphere(radius: 0.05), diffuse: "Moon_diffuse", position: SCNVector3(0, 0, -0.3))
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 36)
        let forever = SCNAction.repeatForever(rotation)
        moonNode.runAction(forever)
        
        return moonNode
    }
    
    private func makeVenusMoonNode() -> SCNNode {
        let moonNode = makePlanet(geometry: SCNSphere(radius: 0.05), diffuse: "Moon_diffuse", position: SCNVector3(0, 0, -0.2))
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degrees2radians), z: 0, duration: 12)
        let forever = SCNAction.repeatForever(rotation)
        moonNode.runAction(forever)
        
        return moonNode
    }
    
    func makePlanet(geometry: SCNGeometry? = nil, diffuse: String? = nil, specular: String? = nil, emission: String? = nil, normal: String? = nil, position: SCNVector3) -> SCNNode {
       
        let planetNode = SCNNode()
        
        if let geom = geometry {
            
            planetNode.geometry = geom
        
            if let diff = diffuse {
                planetNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: diff)
            }
            if let spec = specular {
                planetNode.geometry?.firstMaterial?.specular.contents = UIImage(named: spec)
            }
            if let em = emission {
                planetNode.geometry?.firstMaterial?.emission.contents = UIImage(named: em)
            }
            if let norm = normal {
                planetNode.geometry?.firstMaterial?.normal.contents = UIImage(named: norm)
            }
        }
        
        planetNode.position = position
        
        return planetNode
    }
    
    

}

extension TextureSurfaceViewController: ARSCNViewDelegate {
    
    
    
}

//
//  SCNNode+additions.swift
//  ARKit_tutorial
//
//  Created by Mac on 26/10/2018.
//  Copyright © 2018 Lammax. All rights reserved.
//

import ARKit

extension SCNNode {
    
    func centerPivot() {
        let min = self.boundingBox.min
        let max = self.boundingBox.max
        self.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
}

//
//  MeasureTextNode.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/14.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit

/// MeasureTextNode
class MeasureTextNode: SCNNode {
    
    var textGeometry: SCNText!
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    convenience init(text: String, color: UIColor) {
        self.init()
        
        textGeometry = SCNText(string: text, extrusionDepth: 0.01)
        textGeometry.alignmentMode = kCAAlignmentCenter
        
        if let material = textGeometry.firstMaterial {
            material.diffuse.contents = color
            material.isDoubleSided = true
        }
        
        let textNode = SCNNode(geometry: textGeometry)
        textGeometry.font = UIFont.systemFont(ofSize: 1)
        textNode.scale = SCNVector3Make(0.02, 0.02, 0.02)
        
        // Translate so that the text node can be seen
        let (min, max) = textGeometry.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x)/2, min.y - 0.5, 0)
        
        // Always look at the camera
        let node = SCNNode()
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.all
        node.constraints = [billboardConstraint]
        node.addChildNode(textNode)
        
        addChildNode(node)
    }
    
    func update(text: String) {
        textGeometry?.string = text
    }
    
}

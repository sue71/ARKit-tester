//
//  MeasureLineNode.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/14.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit

/// MeasureLineNode
class MeasureLineNode: SCNNode, MeasureNodeChild {
    
    var selected: Bool = false
    var type: MeasureNodeType! = .line

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    func makeHitTestNode(from: SCNVector3, to: SCNVector3, color: UIColor) -> SCNNode {
        let length = (to - from).length
        let geometry = SCNBox(width: 0.01, height: CGFloat(length), length: 0.01, chamferRadius: 0)
        geometry.materials.first?.diffuse.contents = UIColor.clear
        geometry.name = name
        
        // Adjust position
        let line = SCNNode(geometry: geometry)
        line.name = type.rawValue
        line.position.y = -length/2
        
        // Adjust align
        let align = SCNNode()
        align.eulerAngles.x = .pi/2
        align.addChildNode(line)
        
        // Adjust constraint
        let node = SCNNode()
        node.look(at: to)
        node.addChildNode(align)
        
        return node
    }
    
    convenience init(from: SCNVector3, to: SCNVector3, color: UIColor) {
        self.init()
        
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let lineGeometry = SCNGeometry(sources: [source], elements: [element])
        lineGeometry.materials.first?.diffuse.contents = color
        let lineNode = SCNNode(geometry: lineGeometry)
        
        addChildNode(lineNode)
        addChildNode(makeHitTestNode(from: from, to: to, color: color))
    }
    
}

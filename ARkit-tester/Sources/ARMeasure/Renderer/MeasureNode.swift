//
//  MeasureNode.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/02/27.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit

/// MeasureNode
class MeasureNode: SCNNode {

    /// Child Nodes
    var startNode: MeasureDotNode!
    var endNode: MeasureDotNode!
    var textNode: MeasureTextNode!
    var lineNode: MeasureLineNode?
    
    /// Measure Entity
    var measure: Measure!

    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(measure: Measure) {
        self.init()
        self.measure = measure
        
        // Set position
        position = measure.startPosition

        // Setup start dot
        startNode = MeasureDotNode(color: UIColor.white, type: .start)
        addChildNode(startNode)
        
        // Setup end dot
        endNode = MeasureDotNode(color: UIColor.white, type: .end)
        addChildNode(endNode)
        
        // Setup label node
        textNode = MeasureTextNode(text: "", color: .white)
        addChildNode(textNode)
        
    }
    
    convenience init(from: SCNVector3, sceneView: SCNView) {
        self.init()
        
        position = from

        // Setup start dot
        startNode = MeasureDotNode(color: UIColor.white, type: .start)
        addChildNode(startNode)

        // Setup end dot
        endNode = MeasureDotNode(color: UIColor.white, type: .end)
        addChildNode(endNode)
        
        // Setup label node
        textNode = MeasureTextNode(text: "", color: .white)
        addChildNode(textNode)
        
    }
    
    /// Set selected
    func select(type: MeasureNodeType) {
        switch type {
        case .start:
            startNode.selected = true
        case .end:
            endNode.selected = true
        case .line:
            lineNode?.selected = true
        }
    }
    
    func deselect() {
        startNode.selected = false
        endNode.selected = false
        lineNode?.selected = false
    }
        
    /// Update with measure
    func update(measure: Measure) {
        position = measure.startPosition
        startNode.position = SCNVector3()
        endNode.position = measure.endPosition! - position
        line(from: startNode.position, to: endNode.position)
    }

    /// Update start dot
    func update(start point: SCNVector3) {
        startNode.position = SCNVector3()
        endNode.position = endNode.position + (position - point)
        position = point
        line(from: startNode.position, to: endNode.position)
    }
    
    /// Update end dot
    func update(end point: SCNVector3) {
        line(from: startNode.position, to: point - position)
        endNode.position = point - position
    }
    
    /// Update line
    func line(from: SCNVector3, to: SCNVector3) {
        lineNode?.removeFromParentNode()
        lineNode = MeasureLineNode(from: from, to: to, color: UIColor.white)
        addChildNode(lineNode!)
        
        textNode.update(text: String(format: "%.2fcm", (to - from).length * 100))
    }
    
}

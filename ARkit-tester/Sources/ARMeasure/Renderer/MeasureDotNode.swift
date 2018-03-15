//
//  MeasureDotNode.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/14.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit

class MeasureDotNode: SCNNode, MeasureNodeChild {

    var type: MeasureNodeType!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    var selectedNode: SCNNode?
    
    var selected: Bool = false {
        didSet {
            if selected {
                addSelectedNode()
            } else {
                removeSelectedNode()
            }
        }
    }
    
    func addSelectedNode() {
        let torus = SCNTorus(ringRadius: 0.01, pipeRadius: 0.001)
        let torusNode = SCNNode(geometry: torus)
        torusNode.eulerAngles.x = -.pi/2
        
        let looker = SCNNode()
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = .all
        looker.addChildNode(torusNode)
        looker.constraints = [constraint]
        
        selectedNode = looker
        addChildNode(looker)
    }
    
    func removeSelectedNode() {
        selectedNode?.removeFromParentNode()
    }

    func makeHitTestNode() -> SCNNode {
        let geometry = SCNSphere(radius: 0.01)
        geometry.name = type.rawValue
        geometry.materials.first?.diffuse.contents = UIColor.clear
        let node = SCNNode(geometry: geometry)
        return node
    }
    
    convenience init(color: UIColor = UIColor.white, type: MeasureNodeType) {
        self.init()
        
        self.type = type
        
        let geometry = SCNSphere(radius: 0.001)
        geometry.materials.first?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        
        addChildNode(node)
        addChildNode(makeHitTestNode())
    }
    
    
}

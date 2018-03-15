//
//  MeasureNodeChild.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/14.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit

/// MeasureNodeType
enum MeasureNodeType: String {
    case line = "line"
    case start = "start"
    case end = "end"
}

/// MeasureNodeChild
protocol MeasureNodeChild {
    var type: MeasureNodeType! { get set }
    var selected: Bool { get set }
}

extension SCNNode {
    
    var measureNode: MeasureNode? {
        var node: SCNNode? = self
        while node != nil {
            if let node = node as? MeasureNode {
                return node
            }
            node = node?.parent
        }
        return nil
    }

    /// Get MeasureNode child
    var measureDotNode: MeasureDotNode? {
        var node: SCNNode? = self
        while node != nil {
            if let node = node as? MeasureDotNode {
                return node
            }
            node = node?.parent
        }
        return nil
    }
    
}


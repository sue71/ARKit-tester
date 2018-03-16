//
//  ARKitConfig.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/14.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

struct ARKitConfig {
    var sceneHitTestOptions: [SCNHitTestOption] = []
    var arHitTestOptions: [ARHitTestResult.ResultType] = [.featurePoint]
    var planeDetectionOptions: [ARWorldTrackingConfiguration.PlaneDetection] = [.horizontal]
    
    init() {
        if #available(iOS 11.3, *) {
            arHitTestOptions = [.featurePoint, .existingPlaneUsingGeometry]
            planeDetectionOptions = [.horizontal, .vertical]
        }
    }
    
    static var planeDetectionOptions: [ARWorldTrackingConfiguration.PlaneDetection] {
        if #available(iOS 11.3, *) {
            return [
                .horizontal,
                .vertical
            ]
        }
        return [.horizontal]
    }
    
    static var arHitTestOptions: [ARHitTestResult.ResultType] {
        if #available(iOS 11.3, *) {
            return [
                .featurePoint ,
                .existingPlane,
                .existingPlaneUsingExtent,
                .existingPlaneUsingGeometry,
                .estimatedHorizontalPlane,
                .estimatedVerticalPlane
            ]
        }
        return [
            .featurePoint,
            .existingPlane,
            .estimatedHorizontalPlane,
            .existingPlaneUsingExtent,
        ]
    }
    
    static var sceneHitTestOptions: [SCNHitTestOption] {
        return [
            .backFaceCulling,
            .boundingBoxOnly,
            .clipToZRange,
            .ignoreChildNodes,
            .ignoreHiddenNodes
        ]
    }
    
    static let sceneHitTestSearchMode: [SCNHitTestSearchMode] = [
        .all,
        .any,
        .closest
    ]
}

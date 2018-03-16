//
//  Extensions.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/02/26.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

// MARK: - UIViewController

extension UIViewController {
    
    func present(modalViewController vc: UIViewController, completion: (() -> Void)? = nil) {
        let navigation = UINavigationController(rootViewController: vc)
        navigation.modalTransitionStyle = .coverVertical
        
        present(navigation, animated: true, completion: completion)
    }
    
    func present(popoverViewController vc: UIViewController, completion: (() -> Void)? = nil) {
        let navigation = UINavigationController(rootViewController: vc)
        navigation.modalPresentationStyle = .popover
    
        present(navigation, animated: true, completion: completion)
    }
    
}

// MARK: - StorybaordInstantiable

extension NSObject {
    
    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }

}

protocol StoryboardInstantiable {
    static var storyboardName: String { get }
    static var storyboardIdentifier: String { get }
}

extension StoryboardInstantiable where Self: UIViewController {
    
    static var storyboardName: String { return String(describing: self) }
    static var storyboardIdentifier: String { return String(describing: self) }
    
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        
        if let viewController = storyboard.instantiateInitialViewController() as? Self {
            return viewController
        }
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? Self else {
            fatalError("\(storyboardIdentifier) identifier was not found in \(storyboardName).storyboard")
        }
        
        return viewController
    }
    
}

// MARK: - SceneKit

func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}

extension matrix_float4x4 {
    
    func position() -> SCNVector3 {
        let mat = SCNMatrix4(self)
        return SCNVector3(mat.m41, mat.m42, mat.m43)
    }
    
}

extension SCNVector3 {

    var length: Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
}

// MARK: - ARKitConfig

extension ARWorldTrackingConfiguration.PlaneDetection {
    var name: String  {
        if #available(iOS 11.3, *), self == .vertical {
            return "Vertical"
        } else {
            return "Horizontal"
        }
        
    }
    
}

extension SCNHitTestOption {
    
    var name: String  {
        switch self {
        case .backFaceCulling:
            return "backFaceCulling"
        case .boundingBoxOnly:
            return "boundingBoxOnly"
        case .clipToZRange:
            return "clipToZRange"
        case .ignoreChildNodes:
            return "ignoreChildNodes"
        case .ignoreHiddenNodes:
            return "ignoreHiddenNodes"
        default:
            return ""
        }
    }
    
}

extension ARHitTestResult.ResultType {
    
    var name: String  {
        switch self {
        case .estimatedHorizontalPlane:
            return "Estimated horizontal plane"
        case .existingPlane:
            return "Existing plane"
        case .existingPlaneUsingExtent:
            return "Existing plane using extent"
        case .featurePoint:
            return "Feature point"
        default:
            if #available(iOS 11.3, *) {
                switch self {
                case .existingPlaneUsingGeometry:
                    return "Existing plane using geometry"
                case .estimatedVerticalPlane:
                    return "Estimated vertical plane"
                default:
                    fatalError("")
                    
                }
            }
            fatalError("")
        }
    }
    
    var description: String {
        switch self {
        case .estimatedHorizontalPlane:
            return "現在のフレームから水平面を推測して利用します"
        case .existingPlane:
            return "解析済みの水平面を利用します"
        case .existingPlaneUsingExtent:
            return "解析済みの水平面を拡張して利用します"
        case .featurePoint:
            return "特徴点を利用します"
        default :
            if #available(iOS 11.3, *) {
                switch self {
                case .existingPlaneUsingGeometry:
                    return "解析済みの水平面を形状を基準に利用します"
                case .estimatedVerticalPlane:
                    return "解析済みの垂直面を利用します"
                default:
                    fatalError("")
                }
            }
            
            fatalError("")
        }
    }
    
}

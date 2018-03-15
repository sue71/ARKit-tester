//
//  ARMeasureViewController.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/02/26.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit


/// ARMeasureViewController
class ARMeasureViewController: UIViewController, StoryboardInstantiable {
    
    var measureNodes: [MeasureNode] = []

    let viewModel: ARMeasureViewModel = ARMeasureViewModel()
    
    lazy var lineContainerNode: SCNNode = {
        return SCNNode()
    }()

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var centerView: UIView! {
        didSet {
            centerView.backgroundColor = UIColor.white
            centerView.layer.cornerRadius = centerView.frame.size.width / 2
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = button.frame.size.width / 2
        }
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        guard let position = hitTestPosition() else { return }

        // While editing
        if let measure = viewModel.selectedMeasure, let type = viewModel.selectedNodeType {
            
            if type == .start {
                viewModel.update(id: measure.id, startPosition: position)
            } else {
                viewModel.update(id: measure.id, endPosition: position)
            }
            
            viewModel.endEditing()
            
            return
        }

        let result = hitTestNode()
        // Hit test with node
        if let measureNode = result.measureNode, let type = result.type {
            viewModel.selectMeasure(measure: measureNode.measure, with: type)
            return
        }
        
        viewModel.addMeasure(startPosition: position)
    }
    
    @objc func didTapDebugButton(sender: UIButton) {
        showDebugMenu()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.autoenablesDefaultLighting = false
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.scene = SCNScene()
        sceneView.delegate = self
        sceneView.scene.rootNode.addChildNode(lineContainerNode)
        
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapDebugButton(sender:)))
        navigationItem.rightBarButtonItem = button
        
        viewModel.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pause()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        start()
    }
    
    func restart() {
        lineContainerNode.childNodes.forEach { (node) in
            node.removeFromParentNode()
        }
        pause()
        start()
    }
    
    func start() {
        let config = viewModel.makeTrackingConfiguration()
        sceneView.session.run(config, options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
    }

    func pause() {
        sceneView.session.pause()
    }
    
    func getMeasureNode(measure: Measure) -> MeasureNode? {
        return measureNodes.filter({ $0.measure == measure }).first
    }
    
    func hitTestNode() -> (measureNode: MeasureNode?, type: MeasureNodeType?) {
        var options: [SCNHitTestOption : Any] = viewModel.makeSceneHitTestOptions()
        options[SCNHitTestOption.rootNode] = lineContainerNode
        let results = sceneView.hitTest(sceneView.center, options: options)
        let type = MeasureNodeType(rawValue: results.first?.node.geometry?.name ?? "")
        let node = results.first?.node.measureNode
    
        return (measureNode: node, type: type)
    }
    
    func hitTestPosition() -> SCNVector3? {
        let point = sceneView.center
        let results = sceneView.hitTest(point, types: viewModel.makeARHitTestOptions())
        guard let result = results.first else { return nil }
        
        return result.worldTransform.position()
    }
    
    func showDebugMenu() {
        let vc = DebugViewController.make(with: viewModel.config)
        vc.delegate = self
        present(modalViewController: vc, completion: nil)
    }

}

// MARK: - ARMeasureViewModelDelegate
extension ARMeasureViewController: ARMeasureViewModelDelegate {
    
    func didAddMeasure(viewModel: ARMeasureViewModel, didAddMeasure measure: Measure, measures: [Measure]) {
        let measureNode = MeasureNode(measure: measure)
        lineContainerNode.addChildNode(measureNode)
        measureNodes.append(measureNode)
    }
    
    func didUpdateMeasure(viewModel: ARMeasureViewModel, didUpdateMeasure measure: Measure, measures: [Measure]) {
        let node = measureNodes.filter({$0.measure == measure}).first
        node?.update(measure: measure)
    }
    
    func didRemoveMeasure(viewModel: ARMeasureViewModel, didRemoveMeasure measure: Measure, meaures: [Measure]) {
        measureNodes.filter({$0.measure == measure}).forEach({$0.removeFromParentNode()})
        measureNodes = measureNodes.filter({$0.measure != measure})
    }

    func didChangeConfig(viewModel: ARMeasureViewModel, didChange config: ARKitConfig) {
        self.restart()
    }

}

// MARK: - DebugViewControllerDelegate
extension ARMeasureViewController: DebugViewControllerDelegate {
    
    func debugViewController(vc: DebugViewController, didTapClose sender: UIBarButtonItem) {
        viewModel.config = vc.config
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - ARSCNViewDelegate
extension ARMeasureViewController: ARSCNViewDelegate {
    
    /// Update renderer
    func updateRenderer() {
        
        // Deselect all nodes
        measureNodes.forEach { (node) in
            node.deselect()
        }
        
        // Move point while editing
        if viewModel.isEditing {
            
            guard let position = hitTestPosition() else { return }
            guard let type = viewModel.selectedNodeType else { return }
            guard let measure = viewModel.selectedMeasure else { return }
            
            switch type {
            case .start:
                viewModel.update(id: measure.id, startPosition: position)
            case .end:
                viewModel.update(id: measure.id, endPosition: position)
            case .line:
                break
            }
            
            let node = getMeasureNode(measure: measure)
            node?.select(type: type)
            return
            
        }
        
        // Set selected
        let result = hitTestNode()
        guard let node = result.measureNode, let type = result.type else { return }
        node.select(type: type)
        
    }

    
    /// Rendering is updated
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async(execute: {
            self.updateRenderer()
        })
    }
    
    /// Anchor is added
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Draw plane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.1)
        
        let planeNode = SCNNode(geometry: plane)
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    /// Anchor is updated
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Update plane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    /// Observe tracking status and show them
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .limited(let reason):
            
            if #available(iOS 11.3, *) {
                switch reason {
                case .excessiveMotion:
                    statusLabel.text = "Please move the device slowly"
                case .initializing:
                    statusLabel.text = "Initializing..."
                case .insufficientFeatures:
                    statusLabel.text = "Feature point is insufficient. Please move the device."
                default:
                    if #available(iOS 11.3, *), reason == .relocalizing {
                        statusLabel.text = "ARKit is relocalizing."
                    }
                }
            }
            
        case .normal:
            statusLabel.text = "Feature point is detected. You can measure."
        case .notAvailable:
            statusLabel.text = "ARKit is not available now."
        }
        
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        statusLabel.text = error.localizedDescription
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        statusLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        statusLabel.text = "Interruption ended"
    }
    
}

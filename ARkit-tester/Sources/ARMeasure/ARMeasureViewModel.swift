//
//  ARMeasureViewModel.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/09.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

protocol ARMeasureViewModelDelegate: class {
    func didChangeConfig(viewModel: ARMeasureViewModel, didChange config: ARKitConfig)
    func didAddMeasure(viewModel: ARMeasureViewModel, didAddMeasure measure: Measure, measures: [Measure])
    func didUpdateMeasure(viewModel: ARMeasureViewModel, didUpdateMeasure measure: Measure, measures: [Measure])
    func didRemoveMeasure(viewModel: ARMeasureViewModel, didRemoveMeasure measure: Measure, meaures: [Measure])
}

struct Measure: Equatable{
    
    static func ==(lhs: Measure, rhs: Measure) -> Bool {
        return lhs.id == rhs.id
    }

    static var id: Int = 0
    static func genID() -> Int {
        Measure.id += 1
        return Measure.id
    }
    
    let id = Measure.genID()
    var startPosition: SCNVector3
    var endPosition: SCNVector3?

}

class ARMeasureViewModel {
    
    weak var delegate: ARMeasureViewModelDelegate?
    
    var selectedMeasure: Measure?
    var selectedNodeType: MeasureNodeType?

    var measures: [Measure] = []
    var measuresHistory: [Measure] = []

    var config: ARKitConfig = ARKitConfig() {
        didSet {
            delegate?.didChangeConfig(viewModel: self, didChange: config)
        }
    }
    
    // MARK: - Actions
    
    func selectMeasure(measure: Measure, with nodeType: MeasureNodeType) {
        selectedMeasure = measure
        selectedNodeType = nodeType
    }
    
    func endEditing() {
        selectedNodeType = nil
        selectedMeasure = nil
    }
    
    func getMeasure(by: Int) -> Measure? {
        return measures.filter({ $0.id == by }).first
    }
    
    func addMeasure(startPosition: SCNVector3) {
        let measure = Measure(startPosition: startPosition, endPosition: nil)
        selectedMeasure = measure
        selectedNodeType = .end
        measures.append(measure)
        delegate?.didAddMeasure(viewModel: self, didAddMeasure: measure, measures: measures)
    }
    
    func removeMeasure(id: Int) {
        guard let target = getMeasure(by: id) else {
            fatalError("Cannot find measure")
        }
        measures = measures.filter({$0.id != id})
        delegate?.didRemoveMeasure(viewModel: self, didRemoveMeasure: target, meaures: measures)
    }
    
    func update(id: Int, startPosition: SCNVector3) {
        guard var target = getMeasure(by: id) else {
            fatalError("Cannot find measure")
        }
        target.startPosition = startPosition
        update(target: target)
        delegate?.didUpdateMeasure(viewModel: self, didUpdateMeasure: target, measures: measures)
    }
    
    func update(id: Int, endPosition: SCNVector3) {
        guard var target = getMeasure(by: id) else {
            fatalError("Cannot find measure")
        }
        target.endPosition = endPosition
        update(target: target)
        delegate?.didUpdateMeasure(viewModel: self, didUpdateMeasure: target, measures: measures)
    }

    // MARK: - Computed properties
    
    var isEditing: Bool {
        return selectedMeasure != nil && selectedNodeType != nil
     }

    func makeTrackingConfiguration() -> ARWorldTrackingConfiguration {
        let planeDetection = config.planeDetectionOptions.reduce(ARWorldTrackingConfiguration.PlaneDetection(), { (result, detection) -> ARWorldTrackingConfiguration.PlaneDetection in
            var result = result
            result.insert(detection)
            return result
        })
        let configuration =  ARWorldTrackingConfiguration()
        configuration.planeDetection = planeDetection
        return configuration
    }
    
    func makeSceneHitTestOptions() -> [SCNHitTestOption: Any] {
        return ARKitConfig.sceneHitTestOptions.reduce([:]) { (result, option) -> [SCNHitTestOption: Any] in
            var result = result
            if config.sceneHitTestOptions.contains(option) {
                result[option] = true
            }
            return result
        }
    }
    
    func makeARHitTestOptions() -> ARHitTestResult.ResultType {
        return config.arHitTestOptions.reduce(ARHitTestResult.ResultType(), { (result, type) -> ARHitTestResult.ResultType in
            var result = result
            result.insert(type)
            return result
        })
    }
    
    // MARK: - Collection
    func update(target: Measure) {
        measures = measures.map({ (measure) -> Measure in
            if measure == target {
                return target
            }
            return measure
        })
    }
    
}


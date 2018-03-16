//
//  DebugViewController.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/07.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

protocol DebugViewControllerDelegate: class {
    func debugViewController(vc: DebugViewController, didTapClose sender: UIBarButtonItem)
}

class DebugViewController: UIViewController, StoryboardInstantiable, SelectListViewControllerDelegate {
    
    var delegate: DebugViewControllerDelegate?
    
    enum CellType: Int {
        case planeDetection = 0
        case arHitTestOptions
        case sceneHitTestOptions
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var config: ARKitConfig = ARKitConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
    }

    @objc func didTapCloseButton(sender: UIBarButtonItem) {
        delegate?.debugViewController(vc: self, didTapClose: sender)
    }
    
    static func make(with config: ARKitConfig) -> DebugViewController {
        
        let vc = DebugViewController.instantiate()
        vc.config = config

        return vc
    }

    func showARHitTestOptions() {
        let options = ARKitConfig.arHitTestOptions.map({ SelectOption(title: $0.name, key: $0.name, value: $0) })
        let selectedOptions = config.arHitTestOptions.map({SelectOption(title: $0.name, key: $0.name, value: $0)})
        let vc = SelectListViewController.make(with: SelectListViewController.Props(selected: selectedOptions, options: options), delegate: self)
        vc.view.tag = CellType.arHitTestOptions.rawValue
        present(popoverViewController: vc)
    }
    
    func showSceneHitTestOptions() {
        let options = ARKitConfig.sceneHitTestOptions.map({ SelectOption(title: $0.name, key: $0.name, value: $0) })
        let selectedOptions = config.sceneHitTestOptions.map({SelectOption(title: $0.name, key: $0.name, value: $0)})
        let vc = SelectListViewController.make(with: SelectListViewController.Props(selected: selectedOptions, options: options), delegate: self)
        vc.view.tag = CellType.sceneHitTestOptions.rawValue
        present(popoverViewController: vc)
    }
    
    func showPlaneDetectionOptions() {
        let options = ARKitConfig.planeDetectionOptions.map({ SelectOption(title: $0.name, key: $0.name, value: $0) })
        let selectedOptions = config.planeDetectionOptions.map({SelectOption(title: $0.name, key: $0.name, value: $0)})
        let vc = SelectListViewController.make(with: SelectListViewController.Props(selected: selectedOptions, options: options), delegate: self)
        vc.view.tag = CellType.planeDetection.rawValue
        present(popoverViewController: vc)
    }
    
    func selectListViewController(_ viewController: SelectListViewController, didSelect options: [SelectOption]) {
    }
    
    func selectListViewController(_ viewController: SelectListViewController, didTapCloseButton sender: UIBarButtonItem) {
        guard let type = CellType(rawValue: viewController.view.tag) else { return }
        
        switch type {
        case .arHitTestOptions:
            config.arHitTestOptions = viewController.selectedOptions.map({$0.value as! ARHitTestResult.ResultType})
        case .planeDetection:
            config.planeDetectionOptions = viewController.selectedOptions.map({$0.value as! ARWorldTrackingConfiguration.PlaneDetection})
        case .sceneHitTestOptions:
            config.sceneHitTestOptions = viewController.selectedOptions.map({$0.value as! SCNHitTestOption})
        }
        
        dismiss(animated: true, completion: nil)
    }

}

extension DebugViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = CellType(rawValue: indexPath.row) else { fatalError("Unknown cell type") }
        tableView.deselectRow(at: indexPath, animated: false)
        switch type {
        case .planeDetection:
            showPlaneDetectionOptions()
        case .arHitTestOptions:
            showARHitTestOptions()
        case .sceneHitTestOptions:
            showSceneHitTestOptions()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = CellType(rawValue: indexPath.row) else { fatalError("Unknown cell type")  }
        switch type {
        case .planeDetection:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaneDetection")
            return cell!
        case .arHitTestOptions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARHitTestOptions")
            return cell!
        case .sceneHitTestOptions:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SceneHitTestOptions")
            return cell!
        }
    }
    
}

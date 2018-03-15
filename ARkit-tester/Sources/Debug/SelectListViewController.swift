//
//  SelectListViewController.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/03/09.
//  Copyright © 2018年 sue71. All rights reserved.
//

import Foundation
import UIKit

struct SelectOption {
    var title: String
    var key: AnyHashable
    var value: Any?
}

protocol SelectListViewControllerDelegate: class {
    func selectListViewController(_ viewController: SelectListViewController, didSelect options: [SelectOption])
    func selectListViewController(_ viewController: SelectListViewController, didTapCloseButton sender: UIBarButtonItem)
}

class SelectListViewController: UIViewController, StoryboardInstantiable, UITableViewDataSource, UITableViewDelegate {
    
    struct Props {
        var selected: [SelectOption] = []
        var options: [SelectOption] = []
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SelectListViewControllerDelegate?
    
    var props: Props = Props()
    
    var selectedOptions: [SelectOption] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var options: [SelectOption] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    static func make(with props: Props, delegate: SelectListViewControllerDelegate) -> SelectListViewController {
        let vc = SelectListViewController.instantiate()
        vc.delegate = delegate
        vc.props = props
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        options = props.options
        selectedOptions = props.selected
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(didTapCloseButton(sender:)))
    }
    
    @objc func didTapCloseButton(sender: UIBarButtonItem) {
        delegate?.selectListViewController(self, didTapCloseButton: sender)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let option = options[indexPath.row]
        
        if isChecked(option) {
            selectedOptions = selectedOptions.filter({$0.key != option.key})
        } else {
            selectedOptions.append(option)
        }

        delegate?.selectListViewController(self, didSelect: selectedOptions)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            fatalError("Unknown error")
        }
        
        let option = options[indexPath.row]
        cell.textLabel?.text = option.title
        cell.accessoryType = isChecked(option) ? .checkmark : .none

        return cell
    }
    
    func isChecked(_ option: SelectOption) -> Bool {
        return selectedOptions.contains(where: {$0.key == option.key})
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

//
//  ViewController.swift
//  ARKit-tester
//
//  Created by sue71 on 2018/02/20.
//  Copyright © 2018年 sue71. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {
    
    enum Menu: Int {
        case measure = 0
        
        var title: String {
            switch self {
            case .measure:
                return "Measure"
            }
        }
        
        var viewController: UIViewController {
            switch self {
            case .measure:
                return ARMeasureViewController.instantiate()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = Menu(rawValue: indexPath.row) else { return }
        let vc = menu.viewController
        navigationController?.pushViewController(vc, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className) else { fatalError("") }
        guard let menu = Menu(rawValue: indexPath.row) else { return cell }
        
        cell.textLabel?.text = menu.title
        return cell
    }

}


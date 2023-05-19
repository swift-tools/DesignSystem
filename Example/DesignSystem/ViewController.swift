//
//  ViewController.swift
//  DesignSystem
//
//  Created by lazymisu on 05/18/2023.
//  Copyright (c) 2023 lazymisu. All rights reserved.
//

import UIKit
import DesignSystem

class ViewController: UIViewController {
    @IBOutlet private weak var dropdown: DSDropdown!
    
    private let items = ["DNI", "CE"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: DSDropdownDelegate {
    func numberOfItems(in dropdown: DSDropdown) -> Int {
        return items.count
    }
    
    func dropdown(_ dropdown: DSDropdown, titleForItemAt index: Int) -> String {
        return items[index]
    }
    
    func dropdown(_ dropdown: DSDropdown, didSelectItemAt index: Int) {
        print(items[index])
    }
}

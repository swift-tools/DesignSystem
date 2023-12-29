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
    @IBOutlet private weak var textField: DSTextField!
    
    private let items = ["DNI", "CE"]
    private let domains = ["gmail.com", "hotmail.com",  "yahoo.com", "outlook.com", "yahoo.es", "icloud.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction private func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
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

extension ViewController: DSTextFieldDelegate {
    
    func textField(_ textField: UITextField, didSelectRightButton rightButton: UIButton) {
        print(rightButton)
    }
}

extension ViewController: DSEmailCompletionDelegate {
    
    func numberOfDomains(in emailCompletion: DSEmailCompletion) -> Int {
        return domains.count
    }
    
    func emailCompletion(_ emailCompletion: DSEmailCompletion, titleForDomainAt index: Int) -> String {
        return domains[index]
    }
}

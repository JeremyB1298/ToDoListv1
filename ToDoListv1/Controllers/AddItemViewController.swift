//
//  AddItemViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

protocol AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController,item: Item)
}


class AddItemTableViewController: UITableViewController {

    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    var delegate: AddItemTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtField.becomeFirstResponder()
        //btnDone.isEnabled = false
    }

    @IBAction func actnDone(_ sender: Any) {
        guard let txt = txtField.text else {
            return
        }
        delegate?.addItemFinish(controller: self, item: Item( txt))
    }
    
}
extension AddItemTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = txtField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        if newString?.isEmpty ?? true {
            btnDone.isEnabled = false
        } else {
            btnDone.isEnabled = true
        }
        return true
    }
}

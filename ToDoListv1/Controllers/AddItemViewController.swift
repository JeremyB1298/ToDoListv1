//
//  AddItemViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

protocol AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController, item: Item)
    func editItemFinish(controller: UITableViewController, item: Item)
}


class AddItemTableViewController: UITableViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    var delegate: AddItemTableViewDelegate?
    var itemToEdit: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if itemToEdit != nil {
            navigationController?.title = "Edit Item"
            txtField.text = itemToEdit?.title
            datePicker.date = (itemToEdit?.date)!
        } else {
            navigationController?.title = "Add Item"
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtField.becomeFirstResponder()
        if (txtField.text?.isEmpty)! {
            btnDone.isEnabled = false
        }
    }

    @IBAction func actnDone(_ sender: Any) {
        
        if itemToEdit != nil {
            guard let txt = txtField.text else {
                return
            }
            itemToEdit?.title = txt
            itemToEdit?.date = datePicker.date
            delegate?.editItemFinish(controller: self, item: itemToEdit!)
        } else {
            guard let txt = txtField.text else {
                return
            }
            delegate?.addItemFinish(controller: self, item: Item( txt, datePicker.date))
        }
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

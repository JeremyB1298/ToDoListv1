//
//  AddItemViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

protocol AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController)
    func editItemFinish(controller: UITableViewController)
}


class AddItemTableViewController: UITableViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var datePickerCell: UITableViewCell!
    @IBOutlet weak var lblDateCreate: UILabel!
    @IBOutlet weak var txtFieldDesc: UITextField!
    
    var imagePicker: UIImagePickerController!
    var isDatePickerVisible = false
    var delegate: AddItemTableViewDelegate?
    var itemToEdit: Event? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtField.delegate = self
        if itemToEdit != nil {
            navigationController?.title = "Edit Item"
            txtField.text = itemToEdit?.title
            datePicker.date = (itemToEdit?.date)!
            if itemToEdit?.image != nil {
                imageView.image = UIImage(data: (itemToEdit?.image)!)
            }
            txtFieldDesc.text = itemToEdit?.desc
            initLblDate(date: (itemToEdit?.date)!)
        } else {
            navigationController?.title = "Add Item"
            initLblDate(date: Date())
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
        
    }
    
    func initLblDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        let selectedDate = dateFormatter.string(from: date)
        lblDateCreate.text = selectedDate
    }
    
    func showDatePicker() {
        isDatePickerVisible = true
        //tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 2, section: 3)], with: UITableView.RowAnimation.left)
        //tableView.endUpdates()
        //tableView.reloadData()
        lblDateCreate.textColor = UIColor.blue
    }
    
    func hideDatePicker() {
        isDatePickerVisible = false
        tableView.deleteRows(at: [IndexPath(row: 2, section: 3)], with: UITableView.RowAnimation.right)
        tableView.reloadData()
        lblDateCreate.textColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //txtField.becomeFirstResponder()
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
            itemToEdit?.image = imageView.image?.pngData()
            if let desc = txtFieldDesc.text {
                itemToEdit?.desc = desc
            }
            if let desc = txtFieldDesc.text {
                itemToEdit?.desc = desc
            }
            DataBase.shared().updateEvent(event: itemToEdit!)
            delegate?.editItemFinish(controller: self)
        } else {
            guard let txt = txtField.text else {
                return
            }
            if let image = imageView.image?.pngData() {
                DataBase.shared().insertEvent(title: txt, date: datePicker.date, image: image, desc: txtFieldDesc.text ?? "")
                delegate?.addItemFinish(controller: self)
            } else {
                DataBase.shared().insertEvent(title: txt, date: datePicker.date, desc: txtFieldDesc.text ?? "")
                delegate?.addItemFinish(controller: self)
            }
            
        }
    }
    @IBAction func actnImage(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self 
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3, isDatePickerVisible {
            return 3
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == IndexPath(row: 2, section: 3) {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath == IndexPath(row: 2, section: 3) {
            return 0
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
    }
    
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        if indexPath.row == 0, indexPath.section == 3 {
//            return indexPath
//        }
//        return super.tableView(tableView, willSelectRowAt: indexPath)
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isDatePickerVisible,indexPath.row == 2, indexPath.section == 3 {
            return datePicker.intrinsicContentSize.height + 1
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3, indexPath.row == 0 {
            
            if isDatePickerVisible {
                hideDatePicker()
            } else {
                showDatePicker()
            }
            
        }
    }
    
}
extension AddItemTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtField {
            let nsString = txtField.text as NSString?
            let newString = nsString?.replacingCharacters(in: range, with: string)
            if newString?.isEmpty ?? true {
                btnDone.isEnabled = false
            } else {
                btnDone.isEnabled = true
            }
            return true
        } else {
            return true
        }
        
    }
}
extension AddItemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

}

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
    @IBOutlet weak var lblDateModification: UILabel!
    @IBOutlet weak var txtFieldDesc: UITextField!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblAlarmDetail: UILabel!
    @IBOutlet weak var switchAlarme: UISwitch!
    
    var imagePicker: UIImagePickerController!
    var isDatePickerVisible = false
    var delegate: AddItemTableViewDelegate?
    var itemToEdit: Event?
    var category : Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtField.delegate = self
        if itemToEdit != nil {
            navigationItem.title = "Edit Item"
            category = itemToEdit?.category
            if category != nil {
                lblCategoryName.text = category?.name
            } else {
                lblCategoryName.text = "All"
            }
            txtField.text = itemToEdit?.title
            datePicker.date = (itemToEdit?.dueDate)!
            if itemToEdit?.image != nil {
                imageView.image = UIImage(data: (itemToEdit?.image)!)
            }
            switchAlarme.isOn = itemToEdit!.shouldRemind
            txtFieldDesc.text = itemToEdit?.desc
            lblDateCreate.text = initLblDate(date: (itemToEdit?.date)!)
            lblAlarmDetail.text = initLblDate(date: (itemToEdit?.dueDate)!)
            lblDateModification.text = initLblDate(date: itemToEdit?.dateChange ?? Date())
        } else {
            navigationItem.title = "Add Item"
            lblDateCreate.text = initLblDate(date: Date())
            lblCategoryName.text = "All"
            lblDateModification.text = initLblDate(date: Date())
            lblAlarmDetail.text = initLblDate(date: Date())
        }
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categoryChoice" , let navigation = segue.destination as? UINavigationController {
            let viewController = navigation.topViewController as? ItemCategoryViewController
            viewController?.delegate = self
        }
    }
    
    
    
    @objc private func imageTapped(_ recognizer: UITapGestureRecognizer) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func initLblDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        let selectedDate = dateFormatter.string(from: date)
        return selectedDate
    }
    
    func showDatePicker() {
        isDatePickerVisible = true
        //tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 4, section: 3)], with: UITableView.RowAnimation.left)
        //tableView.endUpdates()
        //tableView.reloadData()
        lblAlarmDetail.textColor = UIColor.blue
    }
    
    func hideDatePicker() {
        isDatePickerVisible = false
        tableView.deleteRows(at: [IndexPath(row: 4, section: 3)], with: UITableView.RowAnimation.right)
        tableView.reloadData()
        lblAlarmDetail.textColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //txtField.becomeFirstResponder()
        txtField.becomeFirstResponder()
        btnDone.isEnabled = txtField.text?.count != 0 ? true : false
    }

    @IBAction func actnDone(_ sender: Any) {
        
        if itemToEdit != nil {
            
            guard let txt = txtField.text else {
                return
            }
            itemToEdit?.title = txt
            itemToEdit?.dueDate = datePicker.date
            itemToEdit?.image = imageView.image?.pngData()
            itemToEdit?.shouldRemind = switchAlarme.isOn
            itemToEdit?.dateChange = Date()
            
            if let desc = txtFieldDesc.text {
                itemToEdit?.desc = desc
            }
            if let cat = category {
                itemToEdit?.category = cat
            }
            DataBase.shared().updateEvent(event: itemToEdit!)
            delegate?.editItemFinish(controller: self)
        } else {
            guard let txt = txtField.text else {
                return
            }
            if let image = imageView.image?.pngData() {
                DataBase.shared().insertEvent(title: txt, date: datePicker.date, image: image, desc: txtFieldDesc.text ?? "", category: category,switchAlarme.isOn)
            } else {
                DataBase.shared().insertEvent(title: txt, date: datePicker.date, desc: txtFieldDesc.text ?? "", category: category,switchAlarme.isOn)

            }
            
            delegate?.addItemFinish(controller: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3, isDatePickerVisible {
            return 5
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == IndexPath(row: 4, section: 3) {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath == IndexPath(row: 4, section: 3) {
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
        if isDatePickerVisible,indexPath.row == 4, indexPath.section == 3 {
            return datePicker.intrinsicContentSize.height + 1
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3, indexPath.row == 3 {
            
            isDatePickerVisible ? hideDatePicker() : showDatePicker()
            
        }
    }
    @IBAction func dateChanged(_ sender: Any) {
        lblAlarmDetail.text = initLblDate(date: datePicker.date)
    }
    
}
extension AddItemTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = txtField.text as NSString?
        guard var newString = nsString?.replacingCharacters(in: range, with: string) else {
            return false
        }
        newString = newString.trimmingCharacters(in: .whitespaces)
        newString = String(newString.filter { !" \n\t\r".contains($0) })
        btnDone.isEnabled = !newString.isEmpty
        return true
    }
}
extension AddItemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
    }
}

extension AddItemTableViewController : ItemCategoryDelegate{
    func choosenCategory(view: ItemCategoryViewController, category: Category) {
        view.dismiss(animated: true, completion: nil)
        self.category = category
        lblCategoryName.text = category.name
    }
    
    
}

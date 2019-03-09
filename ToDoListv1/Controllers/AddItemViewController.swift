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
    func editItemFinish(controller: UITableViewController, item: Event)
}


class AddItemTableViewController: UITableViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    var delegate: AddItemTableViewDelegate?
    var itemToEdit: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if itemToEdit != nil {
            navigationController?.title = "Edit Item"
            txtField.text = itemToEdit?.title
           // datePicker.date = (itemToEdit?.date)!
        } else {
            navigationController?.title = "Add Item"
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
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
            //itemToEdit?.date = datePicker.date
            //delegate?.editItemFinish(controller: self, item: itemToEdit!)
        } else {
            guard let txt = txtField.text else {
                return
            }
            guard let image = imageView.image?.pngData() else {
                return
            }
            DataBase().insertEvent(title: txt, date: datePicker.date, image: image)
            delegate?.addItemFinish(controller: self)
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
extension AddItemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

}

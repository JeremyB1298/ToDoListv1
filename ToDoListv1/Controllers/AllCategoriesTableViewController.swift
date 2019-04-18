//
//  AllCategoriesTableViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 21/03/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

protocol AllCategoriesDelegate {
    func choosedCategory(view: AllCategoriesTableViewController)
}

class AllCategoriesTableViewController: UITableViewController {
    
    var indexpathSelected : IndexPath?
    
    var tabCategories = DataBase.shared().loadCategory()
    
    var delegate : AllCategoriesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoriesCellIdentifier")
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        indexpathSelected = IndexPath(row: UserDefaults.standard.object(forKey: "row") as! Int, section: UserDefaults.standard.object(forKey: "section") as! Int)
    }

    //MARK : - Table View DataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0, indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "All"
            cell.accessoryType = indexpathSelected == IndexPath(row: 0, section: 0) ? .checkmark : .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCellIdentifier", for: indexPath)
            cell.textLabel?.text = tabCategories[indexPath.row].name
            cell.accessoryType = tabCategories[indexPath.row].checked ? .checkmark : .none
            if(tabCategories[indexPath.row].checked){
                indexpathSelected = indexPath
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if indexPath.row == 0 , indexPath.section == 0 || indexPath.row == UserDefaults.standard.integer(forKey: "row") {
            return .none
        }
        else {
            return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return tabCategories.count
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath == IndexPath(row: 0, section: 0) {
            return super.tableView(tableView, indentationLevelForRowAt: indexPath)
        } else {
            return super.tableView(tableView, indentationLevelForRowAt: IndexPath(row: 0, section: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 0, section: 0) {
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else {
            return 50.0
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

            DataBase.shared().deleteCategory(category: tabCategories[indexPath.row])
            tabCategories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.bottom)

        
    }
    
    //MARK : - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexpathSelected != nil, indexPath != indexpathSelected {

            let oldCell = tableView.cellForRow(at: indexpathSelected!)
            oldCell?.accessoryType = UITableViewCell.AccessoryType.none
            tabCategories[indexpathSelected!.row].checked = false
            if indexPath.section != 0 {
                 DataBase.shared().updateCategory(category: tabCategories[indexpathSelected!.row])
            }
           
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        
        
        if indexPath.section != 0 {
            tabCategories[indexPath.row].checked = true
             DataBase.shared().updateCategory(category: tabCategories[indexPath.row])
        }
       
        indexpathSelected = indexPath
        UserDefaults.standard.set(indexpathSelected?.row, forKey: "row")
        UserDefaults.standard.set(indexpathSelected?.section, forKey: "section")
        
        if indexPath.row == 0 , indexPath.section == 0{
            DataModel.shared().category  = nil
        }
        else{
            DataModel.shared().category  = tabCategories[indexPath.row]
        }
        
        DataModel.shared().loadChecklist()
        delegate?.choosedCategory(view: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK : - Buttons Actions
    
    @IBAction func addCategorie(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add category", message: "Name of the category: ", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { Void in
            let firstTextField = alert.textFields?.first
            guard let name = firstTextField?.text else {
                return
            }
            DataBase.shared().insertCategory(name: name, checked: false)
            self.tabCategories  = DataBase.shared().loadCategory()
            self.tableView.reloadData()
        }))
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

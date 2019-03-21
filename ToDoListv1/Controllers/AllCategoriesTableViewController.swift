//
//  AllCategoriesTableViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 21/03/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

class AllCategoriesTableViewController: UITableViewController {

    var categories = ["1","2","3","4"]
    
    var indexpathSelected : IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoriesCellIdentifier")
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == IndexPath(row: 0, section: 0) {
            return super.tableView(tableView, cellForRowAt: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCellIdentifier", for: indexPath)
            cell.textLabel?.text = categories[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return categories.count
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexpathSelected != nil, indexPath != indexpathSelected {

            let oldCell = tableView.cellForRow(at: indexpathSelected!)
            oldCell?.accessoryType = UITableViewCell.AccessoryType.none
            
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        
        indexpathSelected = indexPath
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath != IndexPath(row: 0, section: 0) {
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.bottom)
                
        }
    }
    
    @IBAction func addCategorie(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add category", message: "Name of the category: ", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { Void in
            let firstTextField = alert.textFields?.first
            self.categories.append((firstTextField?.text)!)
            self.tableView.reloadData()
        }))
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Name"
        })
        self.present(alert, animated: true, completion: nil)
        
    }
}

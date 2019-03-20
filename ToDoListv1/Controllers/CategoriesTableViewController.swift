//
//  CategoriesTableViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 18/03/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    
    var tab = ["Carrote","Patate","Poire"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tab.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoriesCellIdentifier") as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = tab[indexPath.row]
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        print(cell?.isSelected)
        if cell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            cell?.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else {
            cell?.accessoryType = .checkmark
        }
        cell?.isSelected = !(cell?.isSelected)!
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = !(cell?.isSelected)!
        print(cell?.isSelected)
    }



}

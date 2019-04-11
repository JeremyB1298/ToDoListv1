//
//  ItemCategoryViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 01/04/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

protocol ItemCategoryDelegate {
    func choosenCategory(view : ItemCategoryViewController,category : Category)
}

class ItemCategoryViewController: UITableViewController {

    var categories = DataBase.shared().loadCategory()
    
    var delegate : ItemCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.choosenCategory(view: self, category: categories[indexPath.row])
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

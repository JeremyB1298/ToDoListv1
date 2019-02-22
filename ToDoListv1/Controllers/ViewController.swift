//
//  ViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var listItem = [Item]()
    var filteredTListItem = [Item]()
    @IBOutlet weak var tableView: UITableView!
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearch()
    }
    
    func initSearch() {
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemIdentifier", let vc = segue.destination as? AddItemTableViewController {
            vc.delegate = self
        }
    }
    
    //MARK: - Actions
    
//    @IBAction func actnAdd(_ sender: Any) {
//
//        let alertController = UIAlertController(title: "ToDoListv1", message: "New item ?", preferredStyle: .alert)
//        alertController.addTextField { (textField : UITextField!) -> Void in
//            textField.placeholder = "Enter Item Name"
//        }
//
//        let okAction = UIAlertAction(title: "ok", style: .default, handler: {(action) in
//
//            let textField = alertController.textFields!.first
//
//            guard let text = textField!.text, !text.isEmpty else {
//                return
//            }
//
//
//        })
//
//        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
//
//        alertController.addAction(okAction)
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")!
        
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTListItem[indexPath.row].title
            if filteredTListItem[indexPath.row].checked == true {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            
            return cell
        }
        else {
            cell.textLabel?.text = listItem[indexPath.row].title
            if listItem[indexPath.row].checked == true {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTListItem.count
        } else {
            return listItem.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentCell = tableView.cellForRow(at: indexPath)
        
        if listItem[indexPath.row].checked == true {
            
            currentCell?.accessoryType = UITableViewCell.AccessoryType.none
            listItem[indexPath.row].checked = false
        } else {
            
            currentCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            listItem[indexPath.row].checked = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        listItem.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredTListItem.removeAll(keepingCapacity: false)
        if searchController.searchBar.text!.lowercased().isEmpty {
            filteredTListItem =  listItem
        } else {
            filteredTListItem =  listItem.filter { $0.title!.contains(searchController.searchBar.text!.lowercased()) }
        }
        self.tableView.reloadData()
    }
    
}

extension ViewController: AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController, item: Item) {
        controller.navigationController?.popViewController(animated: true)
        self.listItem.append(item)
        self.tableView.insertRows(at: [IndexPath(item: self.listItem.count-1, section: 0)], with: UITableView.RowAnimation.top)
    }
}

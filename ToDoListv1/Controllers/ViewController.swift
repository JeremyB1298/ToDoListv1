//
//  ViewController.swift
//  ToDoListv1
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var filteredTListItem = [Event]()
    @IBOutlet weak var tableView: UITableView!
    var resultSearchController = UISearchController()
    var category : Category?
    
    static var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static var dataFileUrl: URL {
        return ViewController.documentDirectory.appendingPathComponent("list").appendingPathExtension("json")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearch()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataModel.shared().loadChecklist()
        tableView.reloadData()
    }
    
    //MARK : Personnal Functions
    
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
    
    func initCellSearchActive(cell: ItemTableViewCell, indexPath: IndexPath ){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        
        cell.lblTitle.text = filteredTListItem[indexPath.row].title
        
        let selectedDate = dateFormatter.string(from: filteredTListItem[indexPath.row].date ?? Date())
        cell.lblDate.text = selectedDate
        if let dataImage = filteredTListItem[indexPath.row].image  {
            cell.imageViewEvent?.image = UIImage(data: dataImage)
        } else {
            cell.imageViewEvent.image = nil
        }
        
        cell.lblCheckmark.isHidden = filteredTListItem[indexPath.row].checked ? false : true
        
    }
    
    func initCell(cell: ItemTableViewCell, indexPath: IndexPath ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        
        cell.lblTitle.text = DataModel.shared().list![indexPath.row].title
        let selectedDate = dateFormatter.string(from: DataModel.shared().list![indexPath.row].date ?? Date())
        cell.lblDate.text = selectedDate
        if let dataImage = DataModel.shared().list![indexPath.row].image  {
            cell.imageViewEvent?.image = UIImage(data: dataImage)
        } else {
            cell.imageViewEvent.image = nil
        }
        cell.lblCheckmark.isHidden = DataModel.shared().list![indexPath.row].checked ? false : true
    }
    
    //MARK : Prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemIdentifier", let vc = segue.destination as? AddItemTableViewController {
            vc.delegate = self
        } else if segue.identifier == "editItemIdentifier", let vc = segue.destination as? AddItemTableViewController {
            vc.delegate = self
            guard let cell = sender as? UITableViewCell, let id = tableView.indexPath(for: cell)?.row else {
                return
            }
            vc.itemToEdit = DataModel.shared().list![id]
        } else if segue.identifier == "listCategories", let vc = segue.destination as? AllCategoriesTableViewController {
            vc.delegate = self
        }

    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK : - Table view DataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") as? ItemTableViewCell else {
            return UITableViewCell()
        }

        if (resultSearchController.isActive) {
           
            initCellSearchActive(cell: cell, indexPath: indexPath)

        } else {
            initCell(cell: cell, indexPath: indexPath)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (resultSearchController.isActive) {
            return filteredTListItem.count
        } else {
            return DataModel.shared().list!.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Alert", message: "Voulez-vous supprimer cet event ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "oui", style: UIAlertAction.Style.destructive, handler: {
            
            action in
            if (self.resultSearchController.isActive) {
                DataBase.shared().deleteEvent(event: self.filteredTListItem[indexPath.row])
                DataModel.shared().list!.remove(at: (DataModel.shared().list?.firstIndex(of: self.filteredTListItem[indexPath.row]))! )
                self.filteredTListItem.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            } else {
                DataBase.shared().deleteEvent(event: DataModel.shared().list![indexPath.row])
                DataModel.shared().list!.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "non", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Table view Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let currentCell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else {
            return
        }
        currentCell.lblCheckmark.isHidden = DataModel.shared().list![indexPath.row].checked ? true : false
        DataModel.shared().list![indexPath.row].checked = DataModel.shared().list![indexPath.row].checked ? false : true
        
    }
    
}

//MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredTListItem.removeAll(keepingCapacity: false)
        
        filteredTListItem = searchController.searchBar.text!.lowercased().isEmpty ? DataModel.shared().list! : DataModel.shared().list!.filter { $0.title?.contains(searchController.searchBar.text!.lowercased()) ?? true }
        
        self.tableView.reloadData()
    }
    
}

//MARK: - AddItemTableViewDelegate

extension ViewController: AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController) {
        controller.navigationController?.popViewController(animated: true)
        DataModel.shared().loadChecklist()
        tableView.reloadData()
    }
    
    func editItemFinish(controller: UITableViewController) {
        controller.navigationController?.popViewController(animated: true)
        
        DataModel.shared().list = DataModel.shared().sortList(list: DataModel.shared().list!)
        tableView.reloadData()
    }

}

//MARK: - AllCategoriesDelegate

extension ViewController: AllCategoriesDelegate {
    func choosedCategory(view: AllCategoriesTableViewController) {
        tableView.reloadData()
    }
}

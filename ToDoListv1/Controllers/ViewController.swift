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
        } else if segue.identifier == "editItemIdentifier", let vc = segue.destination as? AddItemTableViewController {
            vc.delegate = self
            guard let cell = sender as? UITableViewCell, let id = tableView.indexPath(for: cell)?.row else {
                return
            }
            vc.itemToEdit = DataModel.shared().list![id]
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") as? ItemTableViewCell else {
            return UITableViewCell()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        if (resultSearchController.isActive) {
            cell.lblTitle.text = filteredTListItem[indexPath.row].title

            let selectedDate = dateFormatter.string(from: filteredTListItem[indexPath.row].date ?? Date())
            cell.lblDate.text = selectedDate
            if let dataImage = filteredTListItem[indexPath.row].image  {
                cell.imageView?.image = UIImage(data: dataImage)
            }
            if filteredTListItem[indexPath.row].checked == true {
                cell.lblCheckmark.isHidden = false
            } else {
                cell.lblCheckmark.isHidden = true
            }
        } else {
            cell.lblTitle.text = DataModel.shared().list![indexPath.row].title
            let selectedDate = dateFormatter.string(from: DataModel.shared().list![indexPath.row].date ?? Date())
            cell.lblDate.text = selectedDate
            if let dataImage = DataModel.shared().list![indexPath.row].image  {
                cell.imageView?.image = UIImage(data: dataImage)
            }
            if DataModel.shared().list![indexPath.row].checked == true {
                cell.lblCheckmark.isHidden = false
            } else {
                cell.lblCheckmark.isHidden = true
            }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let currentCell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else {
            return
        }
        
        if DataModel.shared().list![indexPath.row].checked == true {
            currentCell.lblCheckmark.isHidden = true
            DataModel.shared().list![indexPath.row].checked = false
            //DataBase().updateEvent(event: DataModel.shared().list![indexPath.row])
        } else {
            currentCell.lblCheckmark.isHidden = false
            DataModel.shared().list![indexPath.row].checked = true
            //DataBase().updateEvent(event: DataModel.shared().list![indexPath.row])
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (resultSearchController.isActive) {
            DataBase.shared().deleteEvent(event: filteredTListItem[indexPath.row])
            DataModel.shared().list!.remove(at: (DataModel.shared().list?.firstIndex(of: filteredTListItem[indexPath.row]))! )
            filteredTListItem.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        } else {
            DataBase.shared().deleteEvent(event: DataModel.shared().list![indexPath.row])
            DataModel.shared().list!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
    }
    
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredTListItem.removeAll(keepingCapacity: false)
        if searchController.searchBar.text!.lowercased().isEmpty {
            filteredTListItem =  DataModel.shared().list!
        } else {
            filteredTListItem =  DataModel.shared().list!.filter { $0.title?.contains(searchController.searchBar.text!.lowercased()) ?? true }
        }
        self.tableView.reloadData()
    }
    
}

extension ViewController: AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController) {
        controller.navigationController?.popViewController(animated: true)
        //DataModel.shared().list = DataModel.shared().sortList(list: DataModel.shared().list!)
        DataModel.shared().loadChecklist()
        tableView.reloadData()
    }
    
    func editItemFinish(controller: UITableViewController) {
        controller.navigationController?.popViewController(animated: true)
        
        DataModel.shared().list = DataModel.shared().sortList(list: DataModel.shared().list!)
        tableView.reloadData()
    }
    
//    func addItemFinish(controller: UITableViewController, item: Event) {
//        controller.navigationController?.popViewController(animated: true)
//        DataModel.shared().list!.append(item)
//        DataModel.shared().list = DataModel.shared().sortList(list: DataModel.shared().list!)
//        tableView.reloadData()
//    }
}

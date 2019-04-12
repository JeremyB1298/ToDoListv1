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
    var sectionName = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
    let collation = UILocalizedIndexedCollation.current()
    var contactsWithSections = [[Event]]()
    var sectionTitles = [String]()
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
        initSection()
        tableView.reloadData()
    }
    
    //MARK : Personnal Functions
    
    func initSection() {
        if resultSearchController.isActive {
            let (arrayContacts, arrayTitles) = collation.partitionObjects(array: filteredTListItem, collationStringSelector: #selector(getter: Event.title))
            contactsWithSections = arrayContacts as! [[Event]]
            sectionTitles = arrayTitles
        } else {
            let (arrayContacts, arrayTitles) = collation.partitionObjects(array: DataModel.shared().list!, collationStringSelector: #selector(getter: Event.title))
            contactsWithSections = arrayContacts as! [[Event]]
            sectionTitles = arrayTitles
        }
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
    
    func initCellSearchActive(cell: ItemTableViewCell, indexPath: IndexPath ){
        let event = contactsWithSections[indexPath.section][indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        
        cell.lblTitle.text = event.title
        
        let selectedDate = dateFormatter.string(from: event.date ?? Date())
        cell.lblDate.text = selectedDate
        if let dataImage = event.image  {
            cell.imageViewEvent?.image = UIImage(data: dataImage)
        } else {
            cell.imageViewEvent.image = nil
        }
        
        cell.lblCheckmark.isHidden = event.checked ? false : true
        
    }
    
    func initCell(cell: ItemTableViewCell, indexPath: IndexPath ) {
        let event = contactsWithSections[indexPath.section][indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy hh:mm at"
        
        cell.lblTitle.text = event.title
        let selectedDate = dateFormatter.string(from: event.date ?? Date())
        cell.lblDate.text = selectedDate
        if let dataImage = event.image  {
            cell.imageViewEvent?.image = UIImage(data: dataImage)
        } else {
            cell.imageViewEvent.image = nil
        }
        cell.lblCheckmark.isHidden = event.checked ? false : true
    }
    
    //MARK : Prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemIdentifier", let vc = segue.destination as? AddItemTableViewController {
            vc.delegate = self
        } else if segue.identifier == "editItemIdentifier", let vc = segue.destination as? AddItemTableViewController {
            vc.delegate = self
            guard let cell = sender as? UITableViewCell, let row = tableView.indexPath(for: cell)?.row,
            let section = tableView.indexPath(for: cell)?.section else {
                return
            }
            vc.itemToEdit = contactsWithSections[section][row]
        } else if segue.identifier == "listCategories", let nav = segue.destination as? UINavigationController, let vc = nav.viewControllers.first as? AllCategoriesTableViewController  {
            vc.delegate = self
        }

    }
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK : - Table view DataSource
        func numberOfSections(in tableView: UITableView) -> Int {
            return sectionTitles.count
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return sectionTitles[section]
        }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return contactsWithSections[section].count
    }
    
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

    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Alert", message: "Voulez-vous supprimer cet event ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "oui", style: UIAlertAction.Style.destructive, handler: {
            
            action in
            if (self.resultSearchController.isActive) {
                DataBase.shared().deleteEvent(event: self.contactsWithSections[indexPath.section][indexPath.row])
                DataModel.shared().list!.remove(at: (DataModel.shared().list?.firstIndex(of: self.contactsWithSections[indexPath.section][indexPath.row]))! )
                self.contactsWithSections[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                if self.contactsWithSections[indexPath.section].count == 0 {
                    self.contactsWithSections.remove(at: indexPath.section)
                    self.contactsWithSections = [[Event]]()
                    self.initSection()
                    let indexSet = IndexSet(arrayLiteral: indexPath.section)
                    tableView.deleteSections(indexSet, with: UITableView.RowAnimation.automatic)
                }
            } else {
                DataBase.shared().deleteEvent(event: self.contactsWithSections[indexPath.section][indexPath.row])
                DataModel.shared().list!.remove(at: (DataModel.shared().list?.firstIndex(of: self.contactsWithSections[indexPath.section][indexPath.row]))! )
                self.contactsWithSections[indexPath.section].remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                if self.contactsWithSections[indexPath.section].count == 0 {
                    self.contactsWithSections.remove(at: indexPath.section)
                    self.contactsWithSections = [[Event]]()
                    self.initSection()
                    let indexSet = IndexSet(arrayLiteral: indexPath.section)
                    tableView.deleteSections(indexSet, with: UITableView.RowAnimation.automatic)
                }
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "non", style: UIAlertAction.Style.cancel, handler: nil))

        if self.presentedViewController != nil {
            self.dismiss(animated: false, completion: nil)
            resultSearchController.searchBar.text = nil
        }
            
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Table view Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let currentCell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else {
            return
        }
        currentCell.lblCheckmark.isHidden = contactsWithSections[indexPath.section][indexPath.row].checked ? true : false
        contactsWithSections[indexPath.section][indexPath.row].checked = !contactsWithSections[indexPath.section][indexPath.row].checked
        
    }
    
}

//MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredTListItem.removeAll(keepingCapacity: false)
        filteredTListItem = searchController.searchBar.text!.lowercased().isEmpty ? DataModel.shared().list! : DataModel.shared().list!.filter { $0.title?.contains(searchController.searchBar.text!.lowercased()) ?? true }
        initSection()
        self.tableView.reloadData()
    }
    
}

//MARK: - AddItemTableViewDelegate

extension ViewController: AddItemTableViewDelegate {
    func addItemFinish(controller: UITableViewController) {
        controller.navigationController?.popViewController(animated: true)
        DataModel.shared().loadChecklist()
        initSection()
        tableView.reloadData()
    }
    
    func editItemFinish(controller: UITableViewController) {
        controller.navigationController?.popViewController(animated: true)
        
        DataModel.shared().list = DataModel.shared().sortList(list: DataModel.shared().list!)
        initSection()
        tableView.reloadData()
    }

}

//MARK: - AllCategoriesDelegate

extension ViewController: AllCategoriesDelegate {
    func choosedCategory(view: AllCategoriesTableViewController) {
        initSection()
        tableView.reloadData()
    }
}
extension UILocalizedIndexedCollation {

    //func for partition array in sections
    func partitionObjects(array:[AnyObject], collationStringSelector:Selector) -> ([AnyObject], [String]) {
        var unsortedSections = [[AnyObject]]()
        //1. Create a array to hold the data for each section
        for _ in self.sectionTitles {
            unsortedSections.append([]) //appending an empty array
        }
        //2. Put each objects into a section
        for item in array {
            let index:Int = self.section(for: item, collationStringSelector:collationStringSelector)
            unsortedSections[index].append(item)
        }
        //3. sorting the array of each sections
        var sectionTitles = [String]()
        var sections = [AnyObject]()
        for index in 0 ..< unsortedSections.count { if unsortedSections[index].count > 0 {
            sectionTitles.append(self.sectionTitles[index])
            sections.append(self.sortedArray(from: unsortedSections[index], collationStringSelector: collationStringSelector) as AnyObject)
            }
        }
        return (sections, sectionTitles)
    }
}

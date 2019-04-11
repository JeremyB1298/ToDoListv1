//
//  DataBase.swift
//  ToDoListv1
//
//  Created by lpiem on 26/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataBase {

    var managedContext: NSManagedObjectContext?
    
    private static var sharedNetworkManager: DataBase = {
        let dataBase = DataBase()
        
        // Configuration
        // ...
        
        return dataBase
    }()

    
    class func shared() -> DataBase {
        return sharedNetworkManager
    }
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    public func insertEvent(title: String, date: Date, image: Data? = nil, desc: String? = "", category: Category? = nil) {
        
        //let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        //"\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! }) + "\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! })
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Event", into: managedContext!) as! Event
        newItem.id = UserDefaults.standard.object(forKey: "idEvent") as! Int64
        newItem.title = title
        newItem.date = date
        newItem.dateChange = Date()
        newItem.checked = false
        if image != nil {
            newItem.image = image
        }
        if category != nil {
            newItem.category = category
        }
        newItem.desc = desc

        
        do {
            try managedContext!.save()
            let id = UserDefaults.standard.object(forKey: "idEvent") as! Int
            UserDefaults.standard.set(id + 1, forKey: "idEvent")
        } catch {
            print("Failed saving")
        }
    }
    
    public func updateEvent(event: Event) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.predicate = NSPredicate(format: "id == \(event.id)")
        request.returnsObjectsAsFaults = false
        do {
            guard let result = try managedContext!.fetch(request) as? [Event] else {
                return
            }
            let eventToUpdate = result[0]
            eventToUpdate.title = event.title
            eventToUpdate.date = event.date
            eventToUpdate.dateChange = Date()
            do {
                try managedContext!.save()
            } catch {
                print("error save update")
            }
            
            
        } catch {
            
            print("Failed")
        }
    }
    
    public func deleteEvent(event: Event) {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.predicate = NSPredicate(format: "id == \(event.id)")
        request.returnsObjectsAsFaults = false
        do {
            guard let result = try managedContext!.fetch(request) as? [Event] else {
                return
            }
            for object in result {
                managedContext!.delete(object)
            }
            do {
                try managedContext!.save()
            } catch {
                print("error save update")
            }
            
            
        } catch {
            
            print("Failed")
        }
    }
    
    //public func insertCategoryAll()
    
    public func insertCategory(name: String, checked: Bool) {
        
        //let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        //"\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! }) + "\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! })
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedContext!) as! Category
       
        newItem.id = UserDefaults.standard.object(forKey: "idCategory") as! Int64
        newItem.name = name
        newItem.checked = checked
        
        do {
            try managedContext!.save()
            let id = UserDefaults.standard.object(forKey: "idCategory") as! Int
            UserDefaults.standard.set(id + 1, forKey: "idCategory")
        } catch {
            print("Failed saving")
        }
    }
    
    public func updateCategory(category: Category) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.predicate = NSPredicate(format: "id == \(category.id)")
        request.returnsObjectsAsFaults = false
        do {
            guard let result = try managedContext!.fetch(request) as? [Category] else {
                return
            }
            let categoryToUpdate = result[0]
            
            categoryToUpdate.checked = category.checked
            
            do {
                try managedContext!.save()
            } catch {
                print("error save update")
            }
            
            
        } catch {
            
            print("Failed")
        }
    }
    
    public func deleteCategory(category: Category) {
        
        if let events = category.events?.allObjects as? [Event] {
            for event in events {
                deleteEvent(event: event)
            }
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.predicate = NSPredicate(format: "id == \(category.id)")
        request.returnsObjectsAsFaults = false
        do {
            guard let result = try managedContext!.fetch(request) as? [Category] else {
                return
            }
            for object in result {
                managedContext!.delete(object)
            }
            do {
                try managedContext!.save()
            } catch {
                print("error save update")
            }
            
            
        } catch {
            
            print("Failed")
        }
    }
    
    public func loadEvent(_ predicate : Category? = nil) -> [Event] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        
        if let category = predicate {
            request.predicate = NSPredicate(format: "category.name == %@", category.name!)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        request.returnsObjectsAsFaults = false
        
        do {
            guard let result = try managedContext.fetch(request) as? [Event] else {
                return []
            }
//            for data in result as! [NSManagedObject] {
//                print(data.value(forKey: "title") as! String)
//            }
            return result
        } catch {
            
            print("Failed")
        }
        return []
    }
    
    public func loadCategory() -> [Category] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            guard let result = try managedContext.fetch(request) as? [Category] else {
                return []
            }
            //            for data in result as! [NSManagedObject] {
            //                print(data.value(forKey: "title") as! String)
            //            }
            return result
        } catch {
            
            print("Failed")
        }
        return []
    }
    
    public func deselctCategory() {
        let tab = loadCategory()
        for category in tab {
            category.checked = false
            updateCategory(category: category)
        }
    }
    
}

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
    
    public func insertEvent(title: String, date: Date, image: Data? = nil, desc: String? = "") {
        
        //let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        //"\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! }) + "\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! })
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Event", into: managedContext!) as! Event
        newItem.id = UserDefaults.standard.object(forKey: "idEvent") as! Int64
        newItem.title = title
        newItem.date = date
        newItem.checked = false
        if image != nil {
            newItem.image = image
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
    
    public func loadData() -> [Event] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        //request.predicate = NSPredicate(format: "age = %@", "12")
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
    
}

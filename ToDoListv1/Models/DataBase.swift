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

    public func insertEvent(title: String, date: Date, image: Data) {
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Event", into: managedContext) as! Event
        newItem.id = "\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! }) + "\(Int.random(in: 0 ... 9999))" + String((0...10).map{ _ in letters.randomElement()! })
        newItem.title = title
        newItem.date = date
        newItem.checked = false
        newItem.image = image
        
        do {
            try managedContext.save()
        } catch {
            print("Failed saving")
        }
    }
    
    public func updateEvent(event: Event) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
        request.predicate = NSPredicate(format: "id = %@", event.id ?? "")
        request.returnsObjectsAsFaults = false
        do {
            guard let result = try managedContext.fetch(request) as? [Event] else {
                return
            }
            let eventToUpdate = result[0]
            eventToUpdate.title = event.title
            eventToUpdate.date = event.date
            
            do {
                try managedContext.save()
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

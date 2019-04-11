//
//  DataModel.swift
//  Checklists
//
//  Created by lpiem on 21/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit

class DataModel {
    
    var list: [Event]?
    var category : Category?
    var sort: String?
    private static var sharedNetworkManager: DataModel = {
        let dataModel = DataModel()
        
        return dataModel
    }()
    
    private init() {
        sort = "title"
        loadChecklist()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveChecklists),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
    }
    
    @objc func saveChecklists() {

        guard let listEvent = list else {
            return
        }
        
        for event in listEvent {
            DataBase.shared().updateEvent(event: event)
        }
        
    }
    
    class func shared() -> DataModel {
        return sharedNetworkManager
    }
    
    func loadChecklist() {
        list = DataBase.shared().loadEvent(category,sort)
    }
    
    func sortList(list: [Event]) -> [Event] {
        if list.count >= 2 {
            //return list.sorted(by: { $0.title < $1.title })
        }else {
            return list
        }
        return list
    }
}

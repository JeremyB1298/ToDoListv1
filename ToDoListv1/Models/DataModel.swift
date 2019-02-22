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
    
    var list: [Item]?
    
    private static var sharedNetworkManager: DataModel = {
        let dataModel = DataModel()
        
        return dataModel
    }()
    
    private init() {
        list = loadChecklist()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveChecklists),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
    }
    
    @objc func saveChecklists() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self.list)
            print(String(data: data, encoding: .utf8)!)
            try data.write(to: ViewController.dataFileUrl)
        } catch {
            print(error)
        }
    }
    
    class func shared() -> DataModel {
        return sharedNetworkManager
    }
    
    private func loadChecklist() -> [Item] {
        if !FileManager.default.fileExists(atPath: ViewController.dataFileUrl.path) {
            return []
        }else {
            do {
                let datas = try Data(contentsOf: ViewController.dataFileUrl)
                
                let decoder = JSONDecoder()
                let list = try decoder.decode([Item].self, from: datas)
                return sortList(list: list)
            }catch {
                print(error)
            }
        }
        return []
    }
    
    func sortList(list: [Item]) -> [Item] {
        if list.count >= 2 {
            return list.sorted(by: { $0.title < $1.title })
        }else {
            return list
        }
    }
}

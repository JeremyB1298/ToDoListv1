//
//  Item.swift
//  ToDoListv1
//
//  Created by lpiem on 22/02/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import UIKit

class Item: Codable, CustomStringConvertible {
    
    var title: String
    var checked: Bool
    var date: Date
    
    init(_ title: String,_ date: Date,_ checked: Bool = false) {
        self.title = title
        self.checked = checked
        self.date = date
    }
    
    var description: String {
        return self.title
    }
}

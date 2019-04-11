//
//  EventExtension.swift
//  ToDoListv1
//
//  Created by lpiem on 11/04/2019.
//  Copyright © 2019 lpiem. All rights reserved.
//

import Foundation
import  UserNotifications

extension Event {
    func deleteNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.id.description])
    }
    
    func scheduleNotification() {
        
        let content = UNMutableNotificationContent()
        deleteNotification()
        content.title = self.title!
        content.body = "EVENT"
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        let calendar = Calendar.current
        
        guard let dueDate = self.dueDate else {
            return
        }
        
        let year = calendar.component(.year, from: dueDate)
        let month = calendar.component(.month, from: dueDate)
        let day = calendar.component(.day, from: dueDate)
        let hour = calendar.component(.hour, from: dueDate)
        let minutes = calendar.component(.minute, from: dueDate)
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minutes
        print(dateComponents)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: self.id.description, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.add(request) { (error) in
            if error != nil {
            }
        }
    }
}

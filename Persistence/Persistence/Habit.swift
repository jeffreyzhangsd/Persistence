//
//  Habit.swift
//  Persistence
//
//  Created by Jeffrey Zhang on 11/8/23.
//

import Foundation
import UIKit

// Habit structure
struct Habit: Codable {
    var name: String
    var timeInterval: Int
    var hasNotifications: Bool
    var note: String?
    
    init(name: String, note: String? = nil, timeInterval: Int = 30, hasNotifications: Bool = false) {
        
        // init to false, 30 min and blank note if not provided
        self.name = name
        self.timeInterval = timeInterval
        self.hasNotifications = hasNotifications
        self.note = note
    }
    
    // save id to habit
    var id: String = UUID().uuidString
}

// Enable saving Habits to local storage
extension Habit {
    
    static var HabitsKey: String {
        return "Habits"
    }
    
    static func save(_ habits: [Habit], forKey key: String) {
        // save habits
        let defaults = UserDefaults.standard
        
        let encodedData = try! JSONEncoder().encode(habits)
        
        defaults.set(encodedData, forKey: key)
    }
    
    static func getHabits(forKey key:String) -> [Habit] {
        // get tasks from local storage
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: key) {
            
            let decodedHabits = try! JSONDecoder().decode([Habit].self, from: data)
            
            return decodedHabits
            
        } else {
            
            return []
        }
    }
    // save updates to habits
    func save() {
        
        var habits = Habit.getHabits(forKey: Habit.HabitsKey)
        
        if let existingIndex = habits.firstIndex(where: {$0.id == self.id}) {
            habits.remove(at: existingIndex)
            
            habits.insert(self, at: existingIndex)
            
        } else {
            
            habits.append(self)
        }
        
        Habit.save(habits, forKey: Habit.HabitsKey)
    }
}

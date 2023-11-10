//
//  HabitCell.swift
//  Persistence
//
//  Created by Jeffrey Zhang on 11/8/23.
//

import UIKit

class HabitCell: UITableViewCell {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    
    var habit: Habit!
    var onCompleteSwitchToggled: ((Habit) -> Void)?
    
    
    @IBAction func didTapSwitch(_ sender: Any) {
        habit.hasNotifications = !habit.hasNotifications
        
        update(with: habit)
        
        onCompleteSwitchToggled?(habit)
    }
    
    
    func configure(with habit: Habit, onCompleteSwitchToggled:  ((Habit) -> Void)?) {
        self.habit = habit
        self.onCompleteSwitchToggled = onCompleteSwitchToggled
        
        update(with: habit)
        
    }
    
    private func update(with habit: Habit) {
        nameLabel.text = habit.name
        intervalLabel.text = String(habit.timeInterval)
        
        // habit.note is an optional
        
        noteLabel.text = habit.note
        
        
        noteLabel.isHidden = habit.note == "" || habit.note == nil
        
        notificationSwitch.isSelected = habit.hasNotifications
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) { }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
}

//
//  HabitComposeViewController.swift
//  Persistence
//
//  Created by Jeffrey Zhang on 11/8/23.
//

import UIKit

class HabitComposeViewController: UIViewController {

    @IBOutlet weak var habitNameField: UITextField!
    @IBOutlet weak var habitTimeField: UITextField!
    @IBOutlet weak var habitNotesTextView: UITextView!
    
    var habitToEdit: Habit?
    
    var onComposeHabit: ((Habit) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let habit = habitToEdit {
            habitNameField.text = habit.name
            
            let timeFieldInt: Int? = Int(habit.timeInterval)
            
            let convertText = String(timeFieldInt!)
            habitTimeField.text = convertText
            
            habitNotesTextView.text = habit.note
            
            self.title = "Edit Habit"
            
            
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCreateButton(_ sender: Any) {
        guard let name = habitNameField.text,
                !name.isEmpty
        else {
            
            return
        }
        
        var habit: Habit
        
        if let editHabit = habitToEdit {
            habit = editHabit
            
            habit.name = name
            habit.timeInterval = Int(habitTimeField.text!)!
            
            habit.note = habitNotesTextView.text
        } else {
            habit = Habit(name: name,
                          note: habitNotesTextView.text, timeInterval: Int(habitTimeField.text!)!)
        }
        
        onComposeHabit?(habit)
        
        dismiss(animated: true)
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }
}

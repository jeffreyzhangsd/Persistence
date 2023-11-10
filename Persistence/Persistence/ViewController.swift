//
//  ViewController.swift
//  Persistence
//
//  Created by Jeffrey Zhang on 11/7/23.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath) as! HabitCell
        
        let habit = habits[indexPath.row]
        
        cell.configure(with: habit, onCompleteSwitchToggled: { [weak self] habit in
            
            habit.save()
            
            self?.refreshHabits()
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedTask = habits[indexPath.row]
        
        performSegue(withIdentifier: "ComposeSegue", sender: selectedTask)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    var habits = [Habit]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // table view init
        tableView.tableHeaderView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // Permission granted
            } else {
                // Handle the case where permission was not granted
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            refreshHabits()
        }

    @IBAction func didTapNewHabitButton(_ sender: Any) {
        performSegue(withIdentifier: "ComposeSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier == "ComposeSegue" {
                
                if let composeNavController = segue.destination as? UINavigationController,
                    
                   let composeViewController = composeNavController.topViewController as? HabitComposeViewController {

                    composeViewController.habitToEdit = sender as? Habit

                    composeViewController.onComposeHabit = { [weak self] habit in
                        habit.save()
                        self?.refreshHabits()
                    }
                }
            }
        }
    
    private func refreshHabits() {
        var habits = Habit.getHabits(forKey: Habit.HabitsKey)
        
        self.habits = habits
        
        emptyStateLabel.isHidden = !habits.isEmpty
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

}

extension ViewController {
    
}

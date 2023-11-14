//
//  ViewController.swift
//  Persistence
//
//  Created by Jeffrey Zhang on 11/7/23.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UNUserNotificationCenterDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitCell", for: indexPath) as! HabitCell
        
        let habit = habits[indexPath.row]
        
        cell.configure(with: habit, onCompleteSwitchToggled: { [weak self] habit in
            
            habit.save()
            
            self?.refreshHabits()
            self?.scheduleNotificationsForAllHabits(self!.habits)
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedTask = habits[indexPath.row]
        
        performSegue(withIdentifier: "ComposeSegue", sender: selectedTask)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Adjust this value based on your cell design
        return 80
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//            removeNotifications(for: habits[indexPath.row])
//            habits.remove(at: indexPath.row)
//
//            Habit.save(habits, forKey: Habit.HabitsKey)
//
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            // Remove notifications, delete the habit, and update the table view
            self?.removeNotifications(for: (self?.habits[indexPath.row])!)
            self?.habits.remove(at: indexPath.row)
            Habit.save(self!.habits, forKey: Habit.HabitsKey)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }

        // Customize the appearance of the delete action
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash.fill")

        // Create a UISwipeActionsConfiguration with the delete action
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])

        // Return the configuration
        return swipeConfig
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
                self.scheduleNotificationsForAllHabits(self.habits)
            } else {
                print("app does not work if notifications are not granted")
            }
        }
       
        UNUserNotificationCenter.current().delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            refreshHabits()
            scheduleNotificationsForAllHabits(self.habits)
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
        let habits = Habit.getHabits(forKey: Habit.HabitsKey)
        
        self.habits = habits
        
        emptyStateLabel.isHidden = !habits.isEmpty
        
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    internal func scheduleNotification(for habit: Habit) {
        let content = UNMutableNotificationContent()
        content.title = "Persistence: \(habit.name)"
        if let note = habit.note, !note.isEmpty {
            content.body = note
        } else {
            content.body = "No additional note"
        }
        content.sound = UNNotificationSound.default

        // Convert habit time to seconds and create a trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(habit.timeInterval * 60), repeats: true)

        // Create a unique identifier for the notification
        let identifier = habit.id

        // Create a request with the content and trigger
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("\(habit.name) scheduled successfully")
            }
        }
    }
    
    internal func scheduleNotificationsForAllHabits(_ habits: [Habit]) {
        for habit in habits {
            if habit.hasNotifications {
                scheduleNotification(for: habit)
            } else {
                removeNotifications(for: habit)
            }
        }
    }
    
    private func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    private func removeNotifications(for habit: Habit) {
        let habitIdentifier = habit.id // assuming habit has an identifier property

        print(habit.name, "notifications have stopped")
        // Remove the specific notification request
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitIdentifier])
    }
}

extension ViewController {
    
}

//
//  SessionListViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 28/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class SessionListViewController: UITableViewController {
//    let realm = try! Realm()
    
    var notificationToken: NotificationToken?
    var realm : Realm?
    var sessions : Results<Session>?
    var selectedModule : Module? {
        didSet{
            loadSessions()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var sessionRoomNo = UITextField()
        var sessionDateTextField = UITextField()
        var sessionTimeTextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Session", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Session", style: .default) { (action) in
            let newSession = Session(roomNo: sessionRoomNo.text!, sessionDate: sessionDateTextField.text!, sessionTime: sessionTimeTextField.text!)
            
            try! self.realm?.write {
                self.selectedModule?.sessions.append(newSession)
                }
            // change session model to let user enter room and time only
//            if let roomNo = sessionRoomNo.text {
//                newSession.roomNo = roomNo
//            }
//            if let sessionDate = sessionDateTextField.text {
//                newSession.sessionDate = sessionDate
//            }
//            if let sessionTime = sessionTimeTextField.text {
//                newSession.sessionTime = sessionTime
//            }
//            self.saveSession(session: newSession)
            print("successfully created a session")
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Room Number"
            sessionRoomNo = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Session Date: DD/MM/YY"
            sessionDateTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Session Time: 08:00-10:00"
            sessionTimeTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK - TableView Datasource method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath)
        if let session = sessions?[indexPath.row] {
            cell.textLabel?.text = String(session.roomNo + " " + session.sessionDate + "-" + session.sessionTime)
        } else {
            cell.textLabel?.text = "No Session Added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToAttendance", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AttendanceListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedSession = sessions?[indexPath.row]
            destinationVC.realm = self.realm
        }
    }
    
    //MARK - Data Manipulation Method
//    func saveSession(session: Session) {
//        if let currentModule = self.selectedModule {
//            do {
//                try realm.write {
//                    currentModule.sessions.append(session)
//                }
//            } catch {
//                print("Error saving session \(error)")
//            }
//        }
//    }
    
    func loadSessions() {
        sessions = selectedModule?.sessions.sorted(byKeyPath: "roomNo")
        tableView.reloadData()
    }
}
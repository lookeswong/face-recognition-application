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
    
    var notificationToken: NotificationToken?
    var realm : Realm?
    var sessions : Results<Session>?
    // set array of session to this var
    var selectedModule : Module? {
        didSet{
            loadSessions()
        }
    }
    var isCheckAttendancePressed: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var sessionRoomNo = UITextField()
        var sessionDateTextField = UITextField()
        var sessionTimeTextField = UITextField()
        
        // add a notification
        let alert = UIAlertController(title: "Add New Session", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Session", style: .default) { (action) in
            let newSession = Session(roomNo: sessionRoomNo.text!, sessionDate: sessionDateTextField.text!, sessionTime: sessionTimeTextField.text!)
            
            // save session to realm database
            try! self.realm?.write {
                self.selectedModule?.sessions.append(newSession)
                }
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
    
    
    //MARK: - TableView Datasource method
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
        if isCheckAttendancePressed == true {
            performSegue(withIdentifier: "goToAttendance", sender: self)
        }
    }
    
    // set variable in next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AttendanceListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedSession = sessions?[indexPath.row]
            destinationVC.realm = self.realm
        }
    }
    
    //MARK: - Data Manipulation Method
    // load array of sessions in a module
    func loadSessions() {
        sessions = selectedModule?.sessions.sorted(byKeyPath: "roomNo")
        tableView.reloadData()
    }
}

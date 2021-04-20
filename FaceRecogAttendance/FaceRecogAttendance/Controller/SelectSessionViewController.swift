//
//  SelectSessionViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class SelectSessionViewController: UITableViewController {
    
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
    
    //MARK - TableView Datasource method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSessionCell", for: indexPath)
        if let session = sessions?[indexPath.row] {
            cell.textLabel?.text = String(session.roomNo + " " + session.sessionDate + "-" + session.sessionTime)
        } else {
            cell.textLabel?.text = "No Session Added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToFaceRecognition", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FaceClassificationViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedSession = sessions?[indexPath.row]
            destinationVC.realm = self.realm
        }
    }
    
    func loadSessions() {
        sessions = selectedModule?.sessions.sorted(byKeyPath: "roomNo")
        tableView.reloadData()
    }
    
    
}

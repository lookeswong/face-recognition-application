//
//  StudentViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 24/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class StudentViewController: UITableViewController {
    
    var notificationToken: NotificationToken?
    var students: Results<Student>?
    var realm : Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onLogin()
    }
    
    //MARK: - Tableview Delegate Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        cell.textLabel?.text = students?[indexPath.row].studentName ?? "No student added yet"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(studentArray[indexPath.row])
        performSegue(withIdentifier: "goToStudentDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! StudentDetailViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.student = students?[indexPath.row]
            destinationVC.realm = self.realm
        }
    }
    //MARK: - Realm Sync Data Manipulation Methods
    // disable notification token if its not in use
    deinit {
        notificationToken?.invalidate()
    }
    
    // check if user is allow to access to synced realm
    func onLogin() {
        let user = app.currentUser!
        let partitionValue = "user=\(user.id)"
        var configuration = user.configuration(partitionValue: partitionValue)
        configuration.objectTypes = [Student.self]
        Realm.asyncOpen(configuration: configuration) { (result) in
            switch result {
            case .failure(let error):
                print("Failed to open realm: \(error)")
            case .success(let realm):
                self.onRealmOpened(realm)
                self.realm = realm
            }
        }
    }
    
    // If user is able to access realm
    func onRealmOpened(_ realm: Realm) {
        students = realm.objects(Student.self)
        
        notificationToken = students?.observe { (changes) in
                switch changes {
                case .initial: break
                    // Results are now populated and can be accessed without blocking the UI
                case .update(_, let deletions, let insertions, let modifications):
                    // Query results have changed.
                    print("Deleted indices: ", deletions)
                    print("Inserted indices: ", insertions)
                    print("Modified modifications: ", modifications)
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
            }
        tableView.reloadData()
    }
    
}

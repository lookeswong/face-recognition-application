//
//  SelectModuleViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class SelectModuleViewController: UITableViewController {
    
    var notificationToken: NotificationToken?
    var realm : Realm?
    var modules : Results<Module>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onLogin()
    }
    
    //MARK - TableView Datasource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectModuleCell", for: indexPath)
        if let module = modules?[indexPath.row] {
            cell.textLabel?.text = String(module.moduleID + " " + module.moduleName)
        } else {
            cell.textLabel?.text = "No Module Added yet"
        }
        return cell
    }
    
    // what happen if user click on a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSelectSession", sender: self)
    }
    
    // set variable in the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SelectSessionViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedModule = modules?[indexPath.row]
            destinationVC.realm = self.realm
        }
    }
    
    //MARK: - REALM SYNC DATA MANIPULATION METHOD
    // disable notification token if its not in use
    deinit {
        notificationToken?.invalidate()
    }
    // check if user can get access to synced realm
    func onLogin() {
        let user = app.currentUser!
        let partitionValue = "user=\(user.id)"
        var configuration = user.configuration(partitionValue: partitionValue)
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
        modules = realm.objects(Module.self)
        
        notificationToken = modules?.observe { (changes) in
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

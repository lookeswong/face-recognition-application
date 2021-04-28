//
//  ModuleListViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 28/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class ModuleListViewController: UITableViewController {
    
    var notificationToken: NotificationToken?
    var realm : Realm?
    var modules : Results<Module>?
    var isCheckAttendancePressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadModules()
        if isCheckAttendancePressed == false {
            // hide the add module button
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            // present the add module button
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        onLogin()
    }
    
    //MARK - TableView Datasource Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modules?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModuleCell", for: indexPath)
        if let module = modules?[indexPath.row] {
            cell.textLabel?.text = String(module.moduleID + " " + module.moduleName)
        } else {
            cell.textLabel?.text = "No Module Added yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToSession", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! SessionListViewController
        if isCheckAttendancePressed == true {
            destinationVC.navigationItem.rightBarButtonItem?.isEnabled = true
            destinationVC.isCheckAttendancePressed = false
        } else {
            destinationVC.navigationItem.rightBarButtonItem?.isEnabled = false
            destinationVC.isCheckAttendancePressed = true
        }
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedModule = modules?[indexPath.row]
            destinationVC.realm = self.realm
        }
    }
    
    //MARK - Data Manipulation Methods
    // function to present all modules from database
//    func loadModules() {
//        modules = realm.objects(Module.self)
//        tableView.reloadData()
//    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // function to create a module object in the database
//    func saveModule(module: Module) {
//        do {
//            try realm.write {
//                realm.add(module)
//            }
//        } catch {
//            print("Error saving module \(error)")
//        }
//    }
    
    //MARK: - Add New Modules
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var moduleNameTextField = UITextField()
        var moduleIDTextField = UITextField()
        
        // create a alert to prompt user enter module details
        let alert = UIAlertController(title: "Add New Module", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Module", style: .default) { (action) in
            // these line happen once the user clicks the Add Module button on our UIAlert
            let newModule = Module(moduleID: moduleIDTextField.text! , moduleName: moduleNameTextField.text!, partition: "user=\(app.currentUser!.id)")
            
            // save module into realm database
            try! self.realm?.write {
                self.realm?.add(newModule)
                }

            print("Successfully created new module")
            
            self.tableView.reloadData()
        }
        
        // adding textfield inside UIAlert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter module Name"
            moduleNameTextField = alertTextField
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter module code"
            moduleIDTextField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // check if user can access to synced realm
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
    
    //MARK: - Data Manipulation Methods
    // if realm is accessed, load the database
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

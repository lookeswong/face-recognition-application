//
//  RegisterViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 21/04/2021.
//

import UIKit
import RealmSwift

class RegisterViewController: UIViewController {
    
//    let realm = try! Realm()
    var notificationToken: NotificationToken?
    var realm : Realm?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var studentIDTextField: UITextField!
    
    var studentID = ""
    var studentName = ""
            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        signUp()
    }
    
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        studentID = studentIDTextField.text!
        studentName = nameTextField.text!
        self.performSegue(withIdentifier: "GoToRecord", sender: self)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if emailTextField.text == "" || nameTextField.text == "" || studentIDTextField.text == "" {
            let alert = UIAlertController.init(title: "Error", message: "Please fill in all the required fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
//        let newStudent = Student()
//        newStudent.email = emailTextField.text!
//        newStudent.password = passwordTextField.text!
//        newStudent.studentName = nameTextField.text!
//        newStudent.studentID = studentIDTextField.text!
//        newStudent.isImageUpload = true
        let newStudent = Student(studentName: nameTextField.text!, studentID: studentIDTextField.text!, email: emailTextField.text!, password: "", isImageUpload: true, isImageTrained: false, partition: "user=\(app.currentUser!.id)")
        
        try! self.realm?.write {
            self.realm?.add(newStudent)
            }
//        self.saveStudent(student: newStudent)
        
        print("successfully registered student")
        self.performSegue(withIdentifier: "goToRegistered", sender: self)
    }
    

//    func saveStudent(student: Student) {
//        do {
//            try self.realm.write {
//                self.realm.add(student)
//            }
//        } catch {
//            print("Error saving category \(error)")
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToRecord" {
            let destinationVC = segue.destination as! FaceTrackerViewController
            destinationVC.studentID = studentID
            destinationVC.studentName = studentName
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @objc func signUp() {
        app.login(credentials: Credentials.anonymous) { (result) in
            // Remember to dispatch back to the main thread in completion handlers
            // if you want to do anything on the UI.
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Login failed: \(error)")
                case .success(let user):
                    print("Login as \(user) succeeded!")
                    // Continue below
                    self.signIn()
                }
            }
        }
    }
    
    @objc func signIn() {
        let user = app.currentUser!
        let partitionValue = "user=\(user.id)"
        var configuration = user.configuration(partitionValue: partitionValue)
        configuration.objectTypes = [Student.self]
        
        Realm.asyncOpen(configuration: configuration) { (result) in
            switch result {
            case .failure(let error):
                print("failed to open realm: \(error)")
            case .success(let realm):
                self.onRealmOpened(realm)
                self.realm = realm
            }
        }
    }
    
    func onRealmOpened(_ realm: Realm) {
        let students = realm.objects(Student.self)
        
        // Retain notificationToken as long as you want to observe
        notificationToken = students.observe { (changes) in
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
        
    }
    
}

// CHANGE THIS TO DELEGATE FUNCTION!!!
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

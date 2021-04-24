//
//  LoginViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 24/04/2021.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkifAdmin(username: String, password: String) -> Bool {
        if username == "admin" && password == "admin" {
            return true
        }
        return false
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToAdmin", sender: self)
    }
}

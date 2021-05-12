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
    var isLogin: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func checkifAdmin(username: String, password: String){
        if username == "admin" && password == "admin" {
            isLogin = true
        }
        isLogin = false
        return
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if isLogin == true {
            performSegue(withIdentifier: "goToAdmin", sender: self)
        } else {
            let alert = UIAlertController.init(title: "Error", message: "Wrong login credentials", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

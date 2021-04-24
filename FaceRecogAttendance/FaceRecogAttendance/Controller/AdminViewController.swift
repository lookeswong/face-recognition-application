//
//  AdminViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 24/04/2021.
//

import Foundation
import UIKit

class AdminViewController: UIViewController {
    
    var isCheckAttendance : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func studentButtonPressed(_ sender: UIButton) {
        isCheckAttendance = 0
        self.performSegue(withIdentifier: "goToStudentList", sender: self)
    }
    
    @IBAction func moduleButtonPressed(_ sender: UIButton) {
        isCheckAttendance = 1
        self.performSegue(withIdentifier: "goToModules", sender: self)
    }
    
    
    @IBAction func checkAttendanceButtonPressed(_ sender: UIButton) {
        isCheckAttendance = 2
        self.performSegue(withIdentifier: "goToModules", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if isCheckAttendance == 1 {
            let destinationVC = segue.destination as! ModuleListViewController
            destinationVC.isCheckAttendancePressed = true
        } else if isCheckAttendance == 2 {
            let destinationVC = segue.destination as! ModuleListViewController
            destinationVC.isCheckAttendancePressed = false
        } else {
            let destinationVC = segue.destination as! StudentViewController
//            destinationVC.isCheckAttendancePressed = false
        }
    }
}

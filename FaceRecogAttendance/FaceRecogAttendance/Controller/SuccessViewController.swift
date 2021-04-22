//
//  SuccessViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 21/04/2021.
//

import Foundation
import UIKit

class SuccessViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

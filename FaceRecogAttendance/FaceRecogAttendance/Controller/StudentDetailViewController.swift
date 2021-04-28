//
//  StudentDetailViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 24/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class StudentDetailViewController: UIViewController {
    
    var realm : Realm?
    var student: Student?
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var studentIDLabel: UILabel!
    @IBOutlet weak var studentEmailLabel: UILabel!
    @IBOutlet weak var imageUploadLabel: UILabel!
    @IBOutlet weak var imageTrainedSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentNameLabel.text = student?.studentName
        studentIDLabel.text = student?.studentID
        studentEmailLabel.text = student?.email
        
        if student?.isImageUpload == true {
            imageUploadLabel.text = "Yes"
        } else {
            imageUploadLabel.text = "No"
        }
        
        if student?.isImageTrained == true {
            imageTrainedSegment.selectedSegmentIndex = 1
        } else {
            imageTrainedSegment.selectedSegmentIndex = 0
        }
        
    }
    
    @IBAction func imageTrainedPressed(_ sender: UISegmentedControl) {
        do {
            try self.realm?.write {
                switch imageTrainedSegment.selectedSegmentIndex
                {
                case 0:
                    student?.isImageTrained = false
                case 1:
                    student?.isImageTrained = true
                default:
                    break
                }
            }
        } catch {
            print("Error saving data")
        }
        
    }
    
}

//
//  AttendanceListViewController.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 28/04/2021.
//

import Foundation
import UIKit
import RealmSwift

class AttendanceListViewController: UITableViewController {
    
//    let realm = try! Realm()

    var notificationToken: NotificationToken?
    var realm : Realm?
    var attendance : Results<Attendance>?
    var selectedSession : Session? {
        didSet {
            loadAttendance()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendance?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath)
        if let attendance = attendance?[indexPath.row]{
            cell.textLabel?.text = attendance.studentName
        } else {
            cell.textLabel?.text = "No Attendance Added"
        }
        return cell
    }
    
    func loadAttendance() {
        attendance = selectedSession?.attendances.sorted(byKeyPath: "studentName")
        tableView.reloadData()
    }
    
    
}

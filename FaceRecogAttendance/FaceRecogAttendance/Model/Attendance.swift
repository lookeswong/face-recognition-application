//
//  Attendance.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import RealmSwift

class Attendance: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var studentID: String = ""
    @objc dynamic var studentName: String = ""
//    @objc dynamic var attendanceTaken: Bool = false
    @objc dynamic var dateCreated: Date?
    
    // relationship
    var parentCategory = LinkingObjects(fromType: Session.self, property: "attendances")
    
    override static func primaryKey() -> String? {
            return "_id"
    }
    
    convenience init(studentID: String, studentName: String, dateCreated: Date?) {
        self.init()
        self.studentID = studentID
        self.studentName = studentName
        self.dateCreated = Date()
    }
}

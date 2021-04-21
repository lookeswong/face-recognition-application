//
//  Session.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import RealmSwift


class Session: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var roomNo: String = ""
    @objc dynamic var sessionDate: String = ""
    @objc dynamic var sessionTime: String = ""
    // relationship
    let attendances = List<Attendance>()
    var parentCategory = LinkingObjects(fromType: Module.self, property: "sessions")
    
    override static func primaryKey() -> String? {
            return "_id"
    }
    
    convenience init(roomNo : String, sessionDate : String, sessionTime: String) {
        self.init()
        self.roomNo = roomNo
        self.sessionDate = sessionDate
        self.sessionTime = sessionTime
    }
}

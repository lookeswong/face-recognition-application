//
//  Student.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import RealmSwift


class Student: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: String = ""
    @objc dynamic var studentName: String = ""
    @objc dynamic var studentID: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var isImageUpload: Bool = false
    @objc dynamic var isImageTrained: Bool = false
    
    override static func primaryKey() -> String? {
            return "_id"
    }
    
    convenience init(studentName: String, studentID: String, email: String, password: String, isImageUpload : Bool = true, isImageTrained : Bool = false, partition: String) {
        self.init()
        self.studentName = studentName
        self.studentID = studentID
        self.email = email
        self.password = password
        self.isImageUpload = isImageUpload
        self.isImageTrained = isImageTrained
        self._partition = partition
    }
}

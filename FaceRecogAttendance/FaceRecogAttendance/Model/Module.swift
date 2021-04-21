//
//  Module.swift
//  FaceRecogAttendance
//
//  Created by Lucas on 20/04/2021.
//

import Foundation
import RealmSwift

class Module: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: String = ""
    @objc dynamic var moduleID: String = ""
    @objc dynamic var moduleName: String = ""
    let sessions = List<Session>()
    
    override static func primaryKey() -> String? {
            return "_id"
    }
    
    convenience init(moduleID: String, moduleName: String, partition: String) {
        self.init()
        self.moduleID = moduleID
        self.moduleName = moduleName
        self._partition = partition
    }
}

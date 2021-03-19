//
//  Folder.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 21.02.2021.
//

import Foundation
import Firebase

struct Folder {
    var name: String?
    var userId: String?
    let uniqueId: String?
    let reference: DatabaseReference?
    
    init(name: String, userId: String, uniqueId: String) {
        self.name = name
        self.userId = userId
        self.uniqueId = uniqueId
        self.reference = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name = snapshotValue["name"] as? String
        self.userId = snapshotValue["userId"] as? String
        self.uniqueId = snapshotValue["uniqueId"] as? String
        self.reference = snapshot.ref
    }
    
    func convertToDictionary() -> Any{
        return ["uniqueId": uniqueId, "name": name, "userId": userId]
    }
    
}

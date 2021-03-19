//
//  AudioNote.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 17.03.2021.
//

import Foundation
import Firebase

struct AudioNote {
    let name: String
    let path: String
    let uniqueId: String
    
    init(name: String, path: String, uniqueId: String) {
        self.name = name
        self.path = path
        self.uniqueId = uniqueId
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        self.name = snapshotValue["name"] as! String
        self.path = snapshotValue["path"] as! String
        self.uniqueId = snapshotValue["uniqueId"] as! String
    }
}


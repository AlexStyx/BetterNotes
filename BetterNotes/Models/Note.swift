//
//  Note.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 10.02.2021.
//

import Foundation
import Firebase

struct Note {
    var headtitle: String?
    var text: String?
    let uniqueId: String?
    var folderName: String?
    let referecne: DatabaseReference?
    
    init(headtitle: String, text: String, uniqueId: String, folderName: String) {
        self.headtitle = headtitle
        self.text = text
        self.uniqueId = uniqueId
        self.folderName = folderName
        self.referecne = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.headtitle = snapshotValue["headtitle"] as! String
        self.text = snapshotValue["text"] as! String
        self.uniqueId = snapshotValue["uniqueId"] as! String
        self.folderName = snapshotValue["folderName"] as! String
        self.referecne = snapshot.ref
    }
    
    func convertToDictionary() -> [String: Any] {
        return ["headtitle": headtitle, "text": text, "uniqueId": uniqueId, "folderName": folderName]
    }
}

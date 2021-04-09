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
    var content: Array<Content>?
    let uniqueId: String?
    var folderName: String?
    let referecne: DatabaseReference?
    
    init(headtitle: String, content: [Content], uniqueId: String, folderName: String) {
        self.headtitle = headtitle
        self.content = content
        self.uniqueId = uniqueId
        self.folderName = folderName
        self.referecne = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.headtitle = snapshotValue["headtitle"] as! String
        self.content = snapshotValue["content"] as! Array<Content>
        self.uniqueId = snapshotValue["uniqueId"] as! String
        self.folderName = snapshotValue["folderName"] as! String
        self.referecne = snapshot.ref
    }
    
    func convertToDictionary() -> [String: Any] {
        return ["headtitle": headtitle, "content": content, "uniqueId": uniqueId, "folderName": folderName]
    }
}

struct Content {
    var contentType: ContentType
    var contentTypeString: String
    var entry: Any
    
    init(contentType: ContentType) {
        self.contentType = contentType
    }
}

enum ContentType {
    case text(text: String)
    case audio(path: URL)
    case photo(path: URL)
}

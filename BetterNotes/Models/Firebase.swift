//
//  Firebase.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 07.02.2021.
//

import Foundation
import Firebase

class Firebase {
    
    let fireBaseAuthentication = Auth.auth()
    
    var ref = Database.database().reference()


//    init(referenceType: ReferecneType) {
//        guard let currentUser = fireBaseAuthentication.currentUser else { return }
//        let client = Client(user: currentUser)
//        switch referenceType {
//        case .folder(let folderId):
//            self.ref = Database.database().reference().child("clients").child(client.uid).child("folders").child(folderId)
//        case .note(let folderId, let noteId):
//            self.ref = Database.database().reference().child("clients").child(client.uid).child("folders").child(folderId).child("notes").child(noteId)
//        case .audioNote(let folderId, let noteId, let audioNoteId):
//            self.ref = Database.database().reference().child("clients").child(client.uid).child("folders").child(folderId).child("notes").child(noteId).child("audioNotes").child(audioNoteId)
//        }
//
//    }
    
    func login(email: String, password: String) {

    }
    
    func register(email: String, password: String) {
        
    }
    
    func checkAuthentication() {
        
    }
    
    func signOut() {

    }
    
}

//enum ReferecneType {
//    case folder(folderId: String)
//    case note(folderID: String,noteId: String)
//    case audioNote(folderId: String, noteId: String, audioNoteId: String)
//}

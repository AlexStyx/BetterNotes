//
//  User.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 10.02.2021.
//

import Foundation
import Firebase
struct Client {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}

//
//  ChatUser.swift
//  ChatApp
//
//  Created by Den on 2020-09-30.
//  Copyright © 2020 Den. All rights reserved.
//

import Foundation
import FirebaseAuth

struct ChatUser {
    var name: String
    let email: String
    var avatar: UIImage?
    init(_ user: User) {
        let defaultUsernameNumber = String(abs(user.uid.hashValue % 1000))
        self.name = "Пользователь №" + defaultUsernameNumber
        self.email = user.email!
    }
}

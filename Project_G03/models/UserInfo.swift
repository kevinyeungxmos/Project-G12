//
//  User.swift
//  Project_G03
//
//  Created by user241431 on 6/30/23.
//

import Foundation

class UserInfo{
    var firstName: String
    var lastName: String
    var email: String
    var iconUrl: String
    
    init(firstName: String, lastName: String, email: String, iconUrl: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.iconUrl = iconUrl
    }
}

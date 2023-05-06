//
//  User.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/04/23.
//

import Foundation
import CoreLocation

enum AccountType: Int {
    case passgenger
    case driver
}

struct User {
    var uid: String
    var fullname: String
    var email: String
    var accountType : AccountType!
    var location: CLLocation?
    
    init(fullname: String, email: String, accountType: AccountType, uid: String) {
        self.fullname = fullname
        self.email = email
        self.accountType = accountType
        self.uid = uid
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        if let index = dictionary["accountTypeIndex"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
        self.uid = uid
    }
}

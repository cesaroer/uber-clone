//
//  User.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/04/23.
//

import Foundation
import CoreLocation

struct User {
    var uid: String
    var fullname: String
    var email: String
    var accountType : Int
    var location: CLLocation?
    
    init(fullname: String, email: String, accountType: Int, uid: String) {
        self.fullname = fullname
        self.email = email
        self.accountType = accountType
        self.uid = uid
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountTypeIndex"] as? Int ?? 0
        self.uid = uid
    }
}

//
//  User.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/04/23.
//

import Foundation
import CoreLocation

struct User {
    var fullname: String
    var email: String
    var accountType : Int
    var location: CLLocation?
    
    init(fullname: String, email: String, accountType: Int) {
        self.fullname = fullname
        self.email = email
        self.accountType = accountType
    }
    
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountTypeIndex"] as? Int ?? 0
    }
}

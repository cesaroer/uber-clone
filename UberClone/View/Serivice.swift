//
//  Serivice.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/04/23.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid
    
    func fetchUserData(_ completion: @escaping((String) -> Void)) {
        REF_USERS.child(currentUid!).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let fullName = dict["fullname"] as? String else {return}
            completion(fullName)
        }
    }
}

//
//  Serivice.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/04/23.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIOS = DB_REF.child("driver-locations")

struct Service {
    static let shared = Service()
    
    func fetchUserData(_ completion: @escaping((User) -> Void)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {return}
            let user = User(dictionary: dict)
            completion(user)
        }
    }
}

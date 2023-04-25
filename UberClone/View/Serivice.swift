//
//  Serivice.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/04/23.
//

import Firebase
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIOS = DB_REF.child("driver-locations")

struct Service {
    static let shared = Service()
    
    func fetchUserData(uid: String? = Auth.auth().currentUser?.uid,
                       _ completion: @escaping((User) -> Void)) {
        guard let currentUid = uid else { return }
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {return}
            let user = User(dictionary: dict)
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation, _ completion: @escaping((User) -> Void)) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIOS)
        
        REF_DRIVER_LOCATIOS.observe(.value) { snapshot in
            
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
        
    }
}

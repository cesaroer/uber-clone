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
let REF_TRIPS = DB_REF.child("trips")


struct Service {
    static let shared = Service()
    
    func fetchUserData(uid: String? = Auth.auth().currentUser?.uid,
                       _ completion: @escaping((User) -> Void)) {
        guard let currentUid = uid else { return }
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else {return}
            //let uid = snapshot.key
            let user = User(uid: currentUid, dictionary: dict)
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

    func uploadTrip(pickupCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D ,
                    uid: String? = Auth.auth().currentUser?.uid, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUid = uid else { return }

        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArra = [destinationCoordinates.latitude, destinationCoordinates.longitude]

        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArra,
                      "state": TripState.requested.rawValue] as [String : Any]

        REF_TRIPS.child(currentUid).updateChildValues(values, withCompletionBlock: completion)
    }

    func observetrips(completion: @escaping(Trip) -> Void ) {
        REF_TRIPS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any],
                  !snapshot.key.isEmpty else { return }
            let passengerUUID = snapshot.key
            let trip = Trip(passengerUUID:passengerUUID , dictionary: dictionary)
            completion(trip)
        }
    }

    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void) {
        REF_TRIPS.child(trip.passengerUUID).observeSingleEvent(of: .childRemoved) { _ in
            completion()
        }
    }

    func acceptTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUUID = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUUID": currentUUID, "state": TripState.accepted.rawValue] as [String : Any]
        REF_TRIPS.child(trip.passengerUUID).updateChildValues(values, withCompletionBlock: completion)
    }

    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let currentUUID = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(currentUUID).observe(.value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            let passengerUUID = snapshot.key
            let trip = Trip(passengerUUID:passengerUUID , dictionary: dict)
            completion(trip)
        }
    }

    func cancelTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUUID = Auth.auth().currentUser?.uid else { return }
        REF_TRIPS.child(currentUUID).removeValue(completionBlock: completion)
    }
}

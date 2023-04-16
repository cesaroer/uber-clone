//
//  HomeController.swift
//  UberClone
//
//  Created by Cesar Vargas on 24/09/21.
//

import UIKit
import Firebase
import MapKit

class HomeController: UIViewController {
    
    
    //MARK: - Properties
    private let mapView = MKMapView()
    static let NotificationDone = NSNotification.Name(rawValue: "Done")
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfUserIsLoggedIn()
        signOut()
    }
    
    //MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if( Auth.auth().currentUser?.uid == nil) {
            print("DEBUG: User not logger In")
            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(name: HomeController.NotificationDone, object: nil)
            }
        }else {
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        }catch let error {
            
            print("DEBUG: Error \(error.localizedDescription)")
        }
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
}

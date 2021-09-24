//
//  HomeController.swift
//  UberClone
//
//  Created by Cesar Vargas on 24/09/21.
//

import UIKit
import Firebase


class HomeController: UIViewController {
    
    
    //MARK: - Properties
    static let NotificationDone = NSNotification.Name(rawValue: "Done")
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //signOut()
        checkIfUserIsLoggedIn()
        view.backgroundColor = .red
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
            
            print("DEBUG: User id is \(Auth.auth().currentUser?.uid)")
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
}

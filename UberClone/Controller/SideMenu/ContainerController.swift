//
//  ContainerController.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 22/05/23.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    //MARK: - Properties
    private let homeController = HomeController()
    private var menuController: MenuController!
    private var isExpanded = false
    private var user: User? {
        didSet {
            guard let user = user else { return }
            configureMenuController(withUser: user)
            homeController.user = user
        }
    }
    
    //MARK: - LifeCicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
    }
    
    //MARK: - API
    private func fetchUserData() {
        Service.shared.fetchUserData { user in
            self.user = user
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(name: HomeController.NotificationDone, object: nil)
            }
        }catch let error {
            print("DEBUG: Error \(error.localizedDescription)")
        }
    }

    //MARK: - Helpers
    func configureHomeController() {
        addChild(homeController)
        homeController.delegate = self
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
    }
    
    func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        menuController.delegate = self

        addChild(menuController)
        menuController.didMove(toParent: self)
        menuController.view.frame = CGRect(x: 0, y: 40,
                                           width: self.view.frame.width,
                                           height: self.view.frame.height - 40)
        view.insertSubview(menuController.view, at: 0)
    }
    
    func animateMenu(shouldExpand: Bool, completion: (() -> Void)? = nil ) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                           options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x  = self.view.frame.width - 80
            } completion: { _ in
                
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0,
                           usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
                           options: .curveEaseInOut) {
                self.homeController.view.frame.origin.x  = 0
            } completion: { _ in
                guard let comp = completion else { return }
                comp()
            }
        }
    }
    
    //MARK: - Selectors
    
}

//MARK: - HomeControllerDelegate
extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}

//MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
    func didSelectOption(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { 
            switch option {
            case .yourTrips:
                break
            case .settings:
                break
            case .logout:
                let alert = UIAlertController(title: nil, message: "Seguro deseas cerrar sesion?",
                                              preferredStyle: .actionSheet)
                let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
                    self.signOut()
                }

                let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(logoutAction)
                alert.addAction(cancel)
                
                self.present(alert, animated: true)
            }
        }
    }
}


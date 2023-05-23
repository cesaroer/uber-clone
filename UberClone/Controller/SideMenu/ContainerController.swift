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
    private let menuController = MenuController()
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

    //MARK: - Helpers
    func configureHomeController() {
        addChild(homeController)
        homeController.delegate = self
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
    }
    
    func configureMenuController(withUser user: User) {
        addChild(menuController)
        menuController.user = user
        menuController.didMove(toParent: self)
        menuController.view.frame = CGRect(x: 0, y: 40,
                                           width: self.view.frame.width,
                                           height: self.view.frame.height - 40)
        view.insertSubview(menuController.view, at: 0)
    }
    
    func animateMenu(shouldExpand: Bool) {
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
                
            }
        }
    }
    
    //MARK: - Selectors
    
}

extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}


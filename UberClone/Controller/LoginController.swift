//
//  LoginController.swift
//  UberClone
//
//  Created by Cesar Vargas on 08/09/21.
//

import UIKit

class LoginController: UIViewController {
    
    //MARK: - Properties

    private let titleLabel : UILabel = {
       
        let label = UILabel()
        label.text = "Uber"
        label.font = UIFont(name: "Avenir", size: 50.0)
        label.textColor = .white
        return label
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}

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
    
    private lazy var emailContainerView: UIView = {
       let view = UIView()
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ic_mail_outline_white_2x")
        imageView.alpha = 0.87
        view.addSubview(imageView)
        
        imageView.centerY(inView: view)
        imageView.anchor(left: view.leftAnchor, paddingLeft: 8, width: 24, height: 24)
        
        view.addSubview(emailTextField)
        emailTextField.centerY(inView: view)
        emailTextField.anchor(left: imageView.rightAnchor, bottom: view.bottomAnchor,
                              right: view.rightAnchor, paddingLeft: 8, paddingBottom: 8)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                             right: view.rightAnchor, paddingLeft: 8, height: 0.75)
        
        return view
    }()
    
    private let emailTextField: UITextField = {
       let tf = UITextField()
        
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return tf
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        titleLabel.centerX(inView: view)
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16, height: 50)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}

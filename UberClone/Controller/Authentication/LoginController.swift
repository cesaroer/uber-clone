//
//  LoginController.swift
//  UberClone
//
//  Created by Cesar Vargas on 08/09/21.
//

import UIKit
import Firebase

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
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField().customTextField(withPlaceholder: "Email",isSecureTextEntry: false)
        tf.textContentType = .emailAddress
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().customTextField(withPlaceholder: "Password",
                                       isSecureTextEntry: true)
    }()
    
    private let loginBtn : AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Login ", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogig), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountBtn : UIButton = {
        let button = UIButton(type: .system)
        let attributtedTittle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.white])
        
        attributtedTittle.append(NSMutableAttributedString(string: "Sign Up", attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 16),
                                                            .foregroundColor: UIColor.mainBlueTint]))
        
        button.setAttributedTitle(attributtedTittle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Helpers
    func configureUI() {
        
        configureNavigationBar()
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 50)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginBtn])
        stack.axis = .vertical
        stack.spacing = 24
        stack.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        stack.layer.cornerRadius = 10
        stack.distribution = .fillEqually
        
        // To add padding the followong lines
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 12)
        
        view.addSubview(stack)
        stack.anchor(left: view.leftAnchor,right: view.rightAnchor,
                     paddingLeft: 16, paddingRight: 16)
        
        stack.centerY(inView: view)
        
        view.addSubview(dontHaveAccountBtn)
               dontHaveAccountBtn.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingBottom: 16 ,paddingRight: 32)
    }
    
    public func configureNavigationBar() {
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    
    //MARK: - System
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: - Selectors
    @objc func handleShowLogin() {
        
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogig() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { result , error in
            if let error =  error {
                print("DEBUG: failer to register user with error \(error.localizedDescription)")
                return
            }

            guard let window = UIApplication.shared.keyWindow,
                  let controller = window.rootViewController as? ContainerController else { return }
            controller.configure()
            self.dismiss(animated: true)
        }
    }

}

//
//  SignUpController.swift
//  UberClone
//
//  Created by Cesar Vargas on 12/09/21.
//

import UIKit
import Firebase

public class SignUpController: UIViewController {
    
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
    
    private lazy var fullnameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullnameTextField)
        view.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return view
    }()
    
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        return view
    }()
    
    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField().customTextField(withPlaceholder: "Email",isSecureTextEntry: false)
        tf.textContentType = .emailAddress
        return tf
    }()
    
    private let fullnameTextField: UITextField = {
        return UITextField().customTextField(withPlaceholder: "Fullname",
                                       isSecureTextEntry: false)
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().customTextField(withPlaceholder: "Password",
                                       isSecureTextEntry: true)
    }()
    
    private let accountTypeSegmentedControl : UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Rider", "Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = .white.withAlphaComponent(0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signUpBtn : AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("SignUp", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)

        return button
    }()
    
    private let alreadyHaveAccountBtn : UIButton = {
        let button = UIButton(type: .system)
        let attributtedTittle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 16),
                        .foregroundColor: UIColor.white])
        
        attributtedTittle.append(NSMutableAttributedString(string: "Login", attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 16),
                                                            .foregroundColor: UIColor.mainBlueTint]))
        
        button.setAttributedTitle(attributtedTittle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        return button
    }()
    
    
    
    //MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Helpers
    func configureUI() {
        
        view.backgroundColor = .backgroundColor
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 50)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   fullnameContainerView,
                                                   passwordContainerView,
                                                   accountTypeContainerView,
                                                   signUpBtn,
                                                   alreadyHaveAccountBtn])
        stack.axis = .vertical
        stack.spacing = 24
        stack.distribution = .fillProportionally
        
        // To add padding the followong lines
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 15, trailing: 12)
        
        view.addSubview(stack)
        stack.anchor(left: view.leftAnchor,right: view.rightAnchor,
                     paddingLeft: 16, paddingRight: 16)
        
        stack.centerY(inView: view)
        
        
        view.addSubview(alreadyHaveAccountBtn)
        alreadyHaveAccountBtn.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingBottom: 16 ,paddingRight: 32)
    }
    
    //MARK: - Selectors
    
    @objc func handleShowSignUp() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullnameTextField.text else {return}


        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            
            if let error =  error {
                print("failer to register user with error \(error)")
                return
            }
            
            guard let uid = result?.user.uid else {return}

            let values = ["email": email,
                          "fullname" : fullname,
                          "accountTypeIndex" : accountTypeIndex] as [String : Any]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values) { error, dbRef in
                
                print("Successfully registered user and saved data")
            }
        }
    }
}

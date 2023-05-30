//
//  UserInfoHeader.swift
//  UberClone
//
//  Created by Cesar Vargas Tapia on 24/05/23.
//

import UIKit

class UserInfoHeader: UIView {

    // MARK: - Properties
    var user: User
    private lazy var profileImageView: UIView = {
       let v = UIView()
        v.backgroundColor = .black
        v.addSubview(initialLabel)
        initialLabel.centerX(inView: v)
        initialLabel.centerY(inView: v)
        return v
    }()

    private lazy var initialLabel: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.text = self.user.firstInitial
        label.font = UIFont.systemFont(ofSize: 28)
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
       let label = UILabel()
        label.text = self.user.fullname
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
       let label = UILabel()
        label.textColor = .lightGray
        label.text = self.user.email
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - LifeCycle
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 64, width: 64)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        
        profileImageView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4

        addSubview(stack)
        stack.centerY(inView: profileImageView,
                      leftAnchor: profileImageView.rightAnchor, paddingLeft: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}

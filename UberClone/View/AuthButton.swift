//
//  AuthButton.swift
//  UberClone
//
//  Created by Cesar Vargas on 12/09/21.
//

import UIKit

class AuthButton: UIButton {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       setTitleColor(.white.withAlphaComponent(0.7), for: .normal)
       backgroundColor = .mainBlueTint
       layer.cornerRadius = 5
       heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

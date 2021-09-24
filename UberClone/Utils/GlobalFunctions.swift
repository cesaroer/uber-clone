//
//  GlobalFunctions.swift
//  UberClone
//
//  Created by Cesar Vargas on 23/09/21.
//

import UIKit



extension UITextField {
    
    
    func addToolBar() {
        
        let tb = UIToolbar()
        
        tb.barStyle = .black
        tb.isTranslucent = true
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        tb.setItems([doneBtn], animated: true)
        tb.isUserInteractionEnabled = true
        tb.sizeToFit()
        
        inputAccessoryView = tb
    }
    
    
    @objc func donePressed() {
        self.endEditing(true)
    }
}



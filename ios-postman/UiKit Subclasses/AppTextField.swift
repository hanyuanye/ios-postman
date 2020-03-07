//
//  AppTextField.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2/13/20.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit

class AppTextField: UITextField {
    
    let padding: UIEdgeInsets
    
    init(padding: UIEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

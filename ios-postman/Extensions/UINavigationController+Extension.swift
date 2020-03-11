//
//  UINavigationController+Extension.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-10.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import UIKit

extension UINavigationController {
    static func standard(_ rootVC: UIViewController) -> UINavigationController {
        let nc = UINavigationController(rootViewController: rootVC)
        
        nc.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        nc.navigationBar.isTranslucent = false
        nc.navigationBar.barTintColor = .black
        nc.navigationBar.tintColor = .blue
        
        return nc
    }
}

//
//  StringArray+Extension.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

extension Array where Element == (String, String) {
    
    var toDict: [String : String] {
        self.reduce(into: [:]) { $0[$1.0] = $1.1 }
    }
    
}

//
//  Array+Extension.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-07.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

extension Array {
    func get(_ index: Int) -> Element? {
        guard index >= 0, index <= endIndex else {
            return nil
        }
        
        return self[index]
    }
}

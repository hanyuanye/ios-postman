//
//  Collection.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation


struct Collection: Codable {
    var environment: Environment
    var requests: [Request]
}

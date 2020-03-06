//
//  Request.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

struct Request: Codable {
    var baseURL: String
    var queryParams: [String : String]
    var headers: [String : String]
    var method: HTTPMethods
    var auth: Auth
}

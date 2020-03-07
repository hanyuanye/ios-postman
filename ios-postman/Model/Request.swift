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
    
    var asURL: URLRequest? {
        guard var components = URLComponents(string: baseURL) else { return nil }
        
        components.scheme = "http"
        components.queryItems = queryParams
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .map { URLQueryItem(name: $0.0, value: $0.1) }
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach {
            guard !$0.0.isEmpty, !$0.1.isEmpty else { return }
            request.setValue($0.1, forHTTPHeaderField: $0.0)
        }
        
        return request
    }
    
}

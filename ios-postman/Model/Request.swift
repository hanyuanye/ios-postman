//
//  Request.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import Differentiator

struct Parameter: Codable, Hashable {
    var key: String
    var value: String
}

struct Request: Codable, IdentifiableType, Equatable, Hashable {
    
    typealias Identity = String
    
    static let empty = Request(baseURL: "", queryParams: [], headers: [], method: .get, auth: .basic, identity: UUID().uuidString)
    
    var baseURL: String
    var queryParams: [Parameter]
    var headers: [Parameter]
    var method: HTTPMethods
    var auth: Auth
    var identity: String
    
    var asURL: URLRequest? {
        guard var components = URLComponents(string: baseURL) else { return nil }
        
        components.scheme = "http"
        components.queryItems = queryParams
            .filter { !$0.key.isEmpty && !$0.value.isEmpty }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach {
            guard !$0.key.isEmpty, !$0.value.isEmpty else { return }
            request.setValue($0.key, forHTTPHeaderField: $0.value)
        }
        
        return request
    }
    
    static func == (lhs: Request, rhs: Request) -> Bool {
        lhs.identity == rhs.identity
    }
    
}

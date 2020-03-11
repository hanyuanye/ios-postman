//
//  Collection.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift


struct Collection: Codable, Hashable, IdentifiableType {
    
    typealias Identity = String
    
    var identity: String
    var environment: Environment
    var requests: [Request]
    var name: String
    
    static var empty: Collection {
        Collection(identity: UUID().uuidString, environment: Environment(variables: [:]), requests: [], name: "Collection")
    }
    
    mutating func add(_ request: Request) -> Int {
        requests.append(request)
        FileProviderCurrent.saveCollection(self)
        return requests.count - 1
    }
}

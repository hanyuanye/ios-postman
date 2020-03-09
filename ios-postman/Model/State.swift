//
//  State.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

var Current = State()

struct State {
    var globalEnvironment: Environment
    var collections: [Collection]
    
    init() {
        let globalEnvsResult = FileProviderCurrent.loadGlobalEnvironment()
        
        if globalEnvsResult.right != nil {
            globalEnvironment = Environment()
            if FileProviderCurrent.saveGlobalEnvironment(globalEnvironment).right != nil {
                fatalError()
            }
        } else {
            globalEnvironment = globalEnvsResult.left!
        }
        
        let collectionResult = FileProviderCurrent.loadCollections()
        
        collections = collectionResult.left ?? []
    }
    
    mutating func addCollection(collection: Collection) {
        collections.append(collection)
    }
    
    func saveAllCollections() {
        collections.forEach { FileProviderCurrent.saveCollection($0) }
    }
}

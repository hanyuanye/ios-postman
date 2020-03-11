//
//  State.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import RxSwift

var Current = State()

func StateModel(
    collections: Observable<[Collection]>,
    addCollection: Observable<Collection>,
    removeCollection: Observable<Int>,
    saveCollection: Observable<Collection>,
    move: Observable<(Int, Int)>
) -> Observable<[Collection]> {
    
    let addRequest = addCollection
        .subscribeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
        .withLatestFrom(collections) { ($0, $1) }
        .map { collection, collections -> [Collection] in
            guard FileProviderCurrent.saveCollection(collection).right == nil else {
                return collections
            }
            
            return collections.appending(collection)
        }
        .debug()
    
    let removeRequest = removeCollection
        .subscribeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
        .withLatestFrom(collections) { ($0, $1) }
        .map { index, collections -> [Collection] in
            guard FileProviderCurrent.removeCollection(collections[index]).right == nil else {
                return collections
            }
            
            return collections.removing(index)
        }
    
    let saveRequest = saveCollection
        .subscribeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
        .withLatestFrom(collections) { ($0, $1) }
        .map { collection, collections -> [Collection] in
            guard let index = collections.firstIndex(where: { $0.identity == collection.identity }),
                  FileProviderCurrent.saveCollection(collection).right == nil else {
                return collections
            }
            
            return collections.replacing(collection, at: index)
        }
    
    let moveRequest = move
        .subscribeOn(SerialDispatchQueueScheduler(qos: .userInitiated))
        .withLatestFrom(collections) { ($0.0, $0.1, $1) }
        .map { source, destination, collections -> [Collection] in
            collections.moving(from: source, to: destination)
        }
        
        
    let newCollection = Observable.merge(
        addRequest,
        removeRequest,
        saveRequest,
        moveRequest
    ).share()
    
    return newCollection
}

class State {
    
    let disposeBag = DisposeBag()
    
    var globalEnvironment: Environment
    let collections = BehaviorSubject<[Collection]>(value: FileProviderCurrent.loadCollections().left ?? [])
    
    let addCollectionPublisher = PublishSubject<Collection>()
    let removeCollectionPublisher = PublishSubject<Int>()
    let saveCollectionPublisher = PublishSubject<Collection>()
    let movePublisher = PublishSubject<(Int, Int)>()
    
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
        
        let newCollections = StateModel(
            collections: collections,
            addCollection: addCollectionPublisher,
            removeCollection: removeCollectionPublisher,
            saveCollection: saveCollectionPublisher,
            move: movePublisher)
        
        disposeBag.insert([
            newCollections.bind(to: collections)
        ])
    }
}

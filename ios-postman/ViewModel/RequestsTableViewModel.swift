//
//  RequestsTableViewModel.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-08.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import RxSwift

func RequestsTableViewModel(
    initial: RequestRxDataSourceModel,
    collection: Observable<Collection>,
    add: Observable<Void>,
    delete: Observable<TableView.Command>,
    move: Observable<TableView.Command>,
    itemSelected: Observable<IndexPath>
) -> (
    Observable<Collection>,
    Observable<Collection>,
    Observable<[RequestRxDataSourceModel]>,
    Observable<MainViewController>
) {
    
    let initialState = collection.map { RequestRxDataSourceModel(items: $0.requests, id: "requests") }.take(1)

    let newState = Observable
        .merge(
            add.map { TableView.Command.Append(Request.empty) },
            delete,
            move
        )
        .scan(initial) { (state: RequestRxDataSourceModel, command: TableView.Command) -> RequestRxDataSourceModel in
            TableView.execute(command: command, state: state)
        }
        .share()
    
    let newCollection = newState
        .withLatestFrom(collection) { ($0.items, $1) }
        .map { requests, collection -> Collection in
            var newCollection = collection
            newCollection.requests = requests
            return newCollection
        }
    
    let save = newCollection
        .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
        
    
    let updateTable = Observable.merge(
        newState,
        initialState
    ).map { [$0] }
    
    let shouldPresentRequest = itemSelected
        .withLatestFrom(collection) { $1.requests[$0.row] }
        .map { MainViewController(request: $0) }
    
    return (newCollection, save, updateTable, shouldPresentRequest)
}

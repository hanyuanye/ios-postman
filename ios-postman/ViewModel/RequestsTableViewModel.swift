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
    move: Observable<TableView.Command>
) -> (
    Observable<Collection>,
    Observable<[RequestRxDataSourceModel]>
) {

    let newState = Observable
        .merge(
            add.map { TableView.Command.Append(Request.empty) },
            delete,
            move
        )
        .scan(initial) { (state: RequestRxDataSourceModel, command: TableView.Command) -> RequestRxDataSourceModel in
            TableView.execute(command: command, state: state)
        }
        .startWith(initial)
        .share()
    
    let saveState = newState
        .withLatestFrom(collection) { ($0.items, $1) }
        .map { requests, collection -> Collection in
            var newCollection = collection
            newCollection.requests = requests
            let result = FileProviderCurrent.saveCollection(collection)
            return result.right == nil ? newCollection : collection
        }
        
    
    let updateTable = newState.map { [$0] }
    
    return (saveState, updateTable)
}

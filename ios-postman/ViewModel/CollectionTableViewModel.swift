//
//  CollectionTableViewModel.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-08.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import RxSwift

func CollectionTableViewModel(
    initial: CollectionRxDataSourceModel,
    collections: Observable<[Collection]>,
    add: Observable<Void>,
    delete: Observable<TableView.Command>,
    move: Observable<TableView.Command>
) -> (
    Observable<[Collection]>,
    Observable<[CollectionRxDataSourceModel]>
) {

    let newState = Observable
        .merge(
            add.map { TableView.Command.Append(Request.empty) },
            delete,
            move
        )
        .scan(initial) { (state: CollectionRxDataSourceModel, command: TableView.Command) -> CollectionRxDataSourceModel in
            TableView.execute(command: command, state: state)
        }
        .startWith(initial)
        .share()
    
    let saveState = newState
        .map { $0.items }
        .distinctUntilChanged { Set($0) == Set($1) }
        
    
    let updateTable = newState.map { [$0] }
    
    return (saveState, updateTable)
}

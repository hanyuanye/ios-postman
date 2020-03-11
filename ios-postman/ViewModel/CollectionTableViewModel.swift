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
    collections: Observable<[Collection]>,
    itemSelected: Observable<IndexPath>
) -> (
    Observable<[CollectionRxDataSourceModel]>,
    Observable<RequestsTableViewController>
) {

    let dataSource = collections
        .scan(CollectionRxDataSourceModel(items: [], id: "")) { CollectionRxDataSourceModel(original: $0, items: $1)}
        .map { [$0] }
    
    let shouldPresentRequestsVC = itemSelected
        .withLatestFrom(collections) { $1[$0.row] }
        .map { RequestsTableViewController(collection: $0) }
    
    return (dataSource, shouldPresentRequestsVC)
}

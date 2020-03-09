//
//  UITableView+Extension.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-08.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

enum TableView {

    enum Command {
        case Append(Any)
        case Move(source: IndexPath, destination: IndexPath)
        case Delete(IndexPath)
    }

    static func execute<T: SectionModelType>(command: Command, state: T) -> T   {
        switch command {
        case .Append(let item):
            guard let item = item as? T.Item else { return state }
            var items = state.items
            items.append(item)
            return T(original: state, items: items)
        case .Delete(let indexPath):
            var items = state.items
            items.remove(at: indexPath.row)
            return T(original: state, items: items)
        case .Move(let source, let destination):
            var items = state.items
            items.insert(items.remove(at: source.row), at: destination.row)
            return T(original: state, items: items)
        }
    }
}

extension Reactive where Base: UITableView {
    var delete: Observable<TableView.Command> {
        base.rx.itemDeleted.asObservable().map(TableView.Command.Delete)
    }
    
    var move: Observable<TableView.Command> {
        base.rx.itemMoved.map(TableView.Command.Move)
    }
}

//
//  Observable+Extension.swift
//  
//
//  Created by Hanyuan Ye on 2/14/20.
//

import Foundation
import RxSwift

extension ObservableType {
    public func filterMap<T>(_ transform: @escaping (Element) -> T?) -> Observable<T> {
        return map(transform)
            .filter { $0 != nil }
            .map { $0! }
    }
}

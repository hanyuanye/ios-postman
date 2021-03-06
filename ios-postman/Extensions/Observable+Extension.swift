//
//  Observable+Extension.swift
//  
//
//  Created by Hanyuan Ye on 2/14/20.
//

import Foundation
import RxSwift
import RxOptional

var scheduler = MainScheduler.instance

extension ObservableType {
    
    public func filterMap<T>(_ transform: @escaping (Element) -> T?) -> Observable<T> {
        map(transform).filterNil()
    }
    
    public func bindOnMain(onNext: @escaping (Element) -> Void) -> Disposable {
        return self
            .observeOn(scheduler)
            .bind(onNext: onNext)
    }
    
    public func scan<A>(_ seed: Observable<A>, accumulator: @escaping(A,Element) throws -> A) -> Observable<A> {
        return seed.take(1).flatMap { self.scan($0, accumulator: accumulator) }
    }
}

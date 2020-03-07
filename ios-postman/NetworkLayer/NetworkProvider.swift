import Foundation
import RxSwift

let NetworkProviderCurrent = NetworkProvider()

struct NetworkProvider {
    
    var performRequest: (URLRequest?) -> Observable<Either<Data, Failure>>
    
    init() {
        let manager = NetworkProviderManager()
        performRequest = { manager.performRequest($0) }
    }
    
    enum Failure {
        case couldNotResolveURL
        case dataTaskError(Error)
        case noResponse
        case statusCodeError(Int)
        case noData
        
        var couldNotResolveURL: Bool {
            if case .couldNotResolveURL = self { return true }
            return false
        }
        
        var dataTaskError: Error? {
            if case .dataTaskError(let error) = self { return error  }
            return nil
        }
        
        var noResponse: Bool {
            if case .noResponse = self { return true }
            return false
        }
        
        var statusCodeError: Int? {
            if case .statusCodeError(let code) = self { return code }
            return nil
        }
        
        var noData: Bool {
            if case .noData = self { return true }
            return false
        }
    }
}

fileprivate struct NetworkProviderManager {
    func performRequest(_ request: URLRequest?) -> Observable<Either<Data, NetworkProvider.Failure>> {
        guard let request = request else { return .just(.right(.couldNotResolveURL))}
         
        return Observable<Either<Data, NetworkProvider.Failure>>.create { observer in
             let cancellable = URLSession.shared.dataTask(with: request) { (data, response, error) in
                 guard error == nil else {
                     observer.onNext(.right(.dataTaskError(error!)))
                     return
                 }
                 
                 guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onNext(.right(.noResponse))
                     return
                 }
                 
                 guard httpResponse.statusCode == 200 else {
                     observer.onNext(.right(.statusCodeError(httpResponse.statusCode)))
                     return
                 }
                 
                 guard let data = data else {
                     observer.onNext(.right(.noData))
                     return
                 }
                 
                 observer.onNext(.left(data))
                 
             }
             
             cancellable.resume()
             
             return Disposables.create {
                 cancellable.cancel()
             }
         }
    }
    
}

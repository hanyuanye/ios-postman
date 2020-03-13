import Foundation
import RxSwift

let NetworkProviderCurrent = NetworkProvider()

struct NetworkProvider {
    
    var performRequest: (URLRequest?) -> Observable<NetworkTimedResponse>
    
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

struct NetworkTimedResponse {
    let data: Either<Data, NetworkProvider.Failure>
    let time: Double
}

fileprivate struct NetworkProviderManager {
    func performRequest(_ request: URLRequest?) -> Observable<NetworkTimedResponse> {
        guard let request = request else { return .just(NetworkTimedResponse(data: .right(.couldNotResolveURL), time: 0)) }
        
        let startTime = CFAbsoluteTimeGetCurrent()
         
        return Observable<NetworkTimedResponse>.create { observer in
             let cancellable = URLSession.shared.dataTask(with: request) { (data, response, error) in
                let duration = CFAbsoluteTimeGetCurrent() - startTime
                let networkResponse: Either<Data, NetworkProvider.Failure>
                
                defer {
                    let timedResponse = NetworkTimedResponse(data: networkResponse, time: duration)
                    observer.onNext(timedResponse)
                }
                
                 guard error == nil else {
                     networkResponse = .right(.dataTaskError(error!))
                     return
                 }
                 
                 guard let httpResponse = response as? HTTPURLResponse else {
                     networkResponse = .right(.noResponse)
                     return
                 }
                 
                 guard httpResponse.statusCode == 200 else {
                     networkResponse = .right(.statusCodeError(httpResponse.statusCode))
                     return
                 }
                 
                 guard let data = data else {
                     networkResponse = .right(.noData)
                     return
                 }
                 
                 networkResponse = .left(data)
             }
             
             cancellable.resume()
             
             return Disposables.create {
                 cancellable.cancel()
             }
         }
    }
    
}

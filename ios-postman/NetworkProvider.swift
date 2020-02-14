import Foundation
import RxSwift

let NetworkProvider = NetworkProviderManager()

struct NetworkProviderManager {
    
    var performRequest: (URLRequest?) -> Observable<Either<Data, Error>>
    
    init() {
        performRequest = { request -> Observable<Either<Data, Error>> in
            guard let request = request else { return .just(.right("Could not resolve URL"))}
            
            return Observable<Either<Data, Error>>.create { observer in
                let cancellable = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    guard error == nil else {
                        observer.onNext(.right(error!))
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        observer.onNext(.right("No Http Response"))
                        return
                    }
                    
                    guard httpResponse.statusCode == 200 else {
                        observer.onNext(.right("Status code returned: \(httpResponse.statusCode)"))
                        return
                    }
                    
                    guard let data = data else {
                        observer.onNext(.right("No data returned"))
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
}

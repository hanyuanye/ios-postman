import Foundation

extension String: Error {}

extension String {
    
    init?<T>(_ value: T?) where T: LosslessStringConvertible {
        guard let value = value else { return nil }
        self.init(value)
    }
    
}

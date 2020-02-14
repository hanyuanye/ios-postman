import Foundation

public enum Either<Left, Right> {
    case left(Left)
    case right(Right)

    public var left: Left? {
        return self.either(ifLeft: Optional.some, ifRight: { _ in Optional.none })
    }

    public var right: Right? {
        return self.either(ifLeft: { _ in Optional.none }, ifRight: Optional.some)
    }

    public func either<A>(ifLeft: (Left) throws -> A, ifRight: (Right) throws -> A) rethrows -> A {
        switch self {
        case let .left(left):
            return try ifLeft(left)
        case let .right(right):
            return try ifRight(right)
        }
    }
    
    public func `do`(ifLeft: (Left) throws -> Void, ifRight: (Right) throws -> Void) rethrows {
        switch self {
        case let .left(left):
            try ifLeft(left)
        case let .right(right):
            try ifRight(right)
        }
    }
}

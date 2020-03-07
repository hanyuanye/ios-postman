//
//  Environment.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

let GlobalEnv = FileProviderCurrent.loadGlobalEnvironment()

struct Environment: Codable {
    
    var variables: [String : String] = [:]
    
    init(_ file: String) {
        
    }
    
    mutating func add(_ value: String, to variable: String) {
        variables[value] = variable
    }
    
    func resolve(variable: String) -> String? {
        return variables[variable]
    }
    
}

// MARK: - Utilities
extension Environment {
    
    enum Failure: Error {
        case conflictResolving
        case couldNotResolve
    }
    
    static func resolve(variable: String, using environments: [Environment]) -> Either<String, Failure> {
        let successfullyResolved = environments.compactMap { $0.resolve(variable: variable) }
        
        switch successfullyResolved.count {
        case 0:
            return .right(.couldNotResolve)
        case 1:
            return .left(successfullyResolved.first!)
        default:
            return .right(.conflictResolving)
        }
    }
    
    static func resolve(text: String, using environments: [Environment]) -> Either<String, [Failure]> {
        let regex = try! NSRegularExpression(pattern: "{{\\w+}}")
        
        let matches = regex
            .matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            .map { (text as NSString).substring(with: $0.range) }
        
        let variables = matches
            .compactMap { Environment.resolve(variable: $0, using: environments) }
        
        let errors = variables
            .compactMap { $0.right }
        
        guard errors.count == 0 else {
            return .right(errors)
        }
        
        let resolvedValues = variables
            .compactMap { $0.left }
        
        let resolvingDict = Dictionary(zip(matches, resolvedValues)) { (first, _) in first }
        
        let resolvedText = resolvingDict
            .reduce(text) { $0.replacingOccurrences(of: $1.key, with: $1.value) }
        
        return .left(resolvedText)
    }
    
}

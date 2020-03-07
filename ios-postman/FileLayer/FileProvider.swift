//
//  FileProvider.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-06.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

let FileProviderCurrent = FileProvider()

struct FileProvider {
    
    var saveCollection: (Collection) -> Either<Void, Failure>
    var loadCollections: () -> Either<[Collection], Failure>
    var loadGlobalEnvironment: () -> Either<Environment, Failure>
    
    init() {
        let manager = FileProviderManager()
        saveCollection = { manager.saveCollection($0) }
        loadCollections = { manager.loadCollections() }
        loadGlobalEnvironment = { manager.loadGlobalEnvironment() }
    }
    
    enum Failure {
        case noDirectory
        case encodeFailure
        case decodeFailure
        case fileSystemError(Error)
    }
    
}

fileprivate struct FileProviderManager {
    
    var baseURL: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    func saveCollection(_ collection: Collection) -> Either<Void, FileProvider.Failure> {
        guard let baseURL = baseURL else {
            return .right(.noDirectory)
        }
        
        guard let data = try? JSONEncoder().encode(collection) else {
            return .right(.encodeFailure)
        }
        
        let fileURL = baseURL.appendingPathComponent(collection.id)
        
        
        do {
            try data.write(to: fileURL)
            return .left(())
        } catch {
            return .right(.fileSystemError(error))
        }
    }
    
    func loadCollections() -> Either<[Collection], FileProvider.Failure> {
        guard let baseURL = baseURL else {
            return .right(.noDirectory)
        }
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil, options: []) else {
            return .right(.noDirectory)
        }
        
        let collections = files
            .compactMap { try? Data(contentsOf: $0) }
            .compactMap { try? JSONDecoder().decode(Collection.self, from: $0) }
        
        return .left(collections)
    }
    
    func loadGlobalEnvironment() -> Either<Environment, FileProvider.Failure> {
        guard let baseURL = baseURL else {
            return .right(.noDirectory)
        }
        
        let environmentURL = baseURL.appendingPathComponent("GlobalEnvironment")
        
        guard let data = try? Data(contentsOf: environmentURL),
              let environment = try? JSONDecoder().decode(Environment.self, from: data) else {
                return .right(.decodeFailure)
        }
        
        return .left(environment)
    }
    
}

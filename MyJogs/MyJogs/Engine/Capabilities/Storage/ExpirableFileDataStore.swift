//
//  ExpirableFileDataStore.swift
//  MyJogs
//
//  Created by thomas lacan on 03/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

public class ExpirableFileDataStore {
    
    static let kExpirationTimeForPathsFilename = "cacheValidity"
    
    let dataStore: FileDataStore
    var updatedTimeForPaths: [String: Date] {
        didSet {
            dataStore.persist(
                codable: updatedTimeForPaths,
                filename: ExpirableFileDataStore.kExpirationTimeForPathsFilename,
                in: dataStore.rootDirectory()
            )
        }
    }
    
    init(dataStore: FileDataStore) {
        self.dataStore = dataStore
        updatedTimeForPaths = dataStore.codable(
            from: ExpirableFileDataStore.kExpirationTimeForPathsFilename,
            in: dataStore.rootDirectory()
            ) ?? [String: Date]()
    }
    
    func persist<T: Codable>(codable: T, filename: String, in directory: String) {
        let key = cacheKey(for: filename, in: directory)
        if dataStore.persist(codable: codable, filename: filename, in: directory) != nil {
            updatedTimeForPaths[key] = Date()
        } else {
            LOG("[ExpirableFileDataStore] Unable to persist \(codable)")
        }
    }
    
    func codable<T: Codable>(from filename: String, in directory: String, maxValidity: TimeInterval? = nil) -> T? {
        guard isCacheValid(from: filename, in: directory, maxValidity: maxValidity) else {
            return nil
        }
        return dataStore.codable(from: filename, in: directory)
    }
    
    func isCacheValid(from filename: String, in directory: String, maxValidity: TimeInterval? = nil) -> Bool {
        let key = cacheKey(for: filename, in: directory)
        guard let lastCacheDate = updatedTimeForPaths[key] else {
            return false
        }
        if  let maxValidity = maxValidity,
            lastCacheDate.addingTimeInterval(maxValidity) < Date() {
            return false
        }
        return true
    }
    
    func deleteFileIfExists(in directory: String, filename: String) {
        dataStore.deleteFileIfExists(in: directory, filename: filename)
        invalidateCache(from: filename, in: directory)
    }
    
    func invalidateCache(from filename: String, in directory: String) {
        let key = cacheKey(for: filename, in: directory)
        updatedTimeForPaths.removeValue(forKey: key)
    }
    
    private func cacheKey(for filename: String, in directory: String) -> String {
        return filename // FIXME: Return filename relative path to rootDirectory
    }
}

extension ExpirableFileDataStore: EngineComponent {
    func onLogoutUser() {
        
    }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) {
        
    }
}

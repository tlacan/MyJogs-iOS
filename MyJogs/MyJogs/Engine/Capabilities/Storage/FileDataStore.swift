//
//  FileDataStore.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

class FileDataStore {
    
    let testEnv: Bool
    
    init(testEnv: Bool = false) {
        self.testEnv = testEnv
        print("[FileDataStore] Using directory \(rootDirectory())")
    }
    
    @discardableResult
    func persist<T: Codable>(codable: T, filename: String, in directory: String) -> String? {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(codable)
            do {
                return try persist(data: encoded, in: directory, filename: filename)
            } catch let error {
                LOG("[FileDatastore] Error persisting \(codable) to \(filename)) \(error)", .error)
                return nil
            }
        } catch let error {
            LOG("[FileDatastore] Unable to encode \(codable) -> \(error)")
            return nil
        }
    }
    
    func codable<T: Codable>(from filename: String, in directory: String) -> T? {
        do {
            let data = try self.data(
                from: directory,
                filename: filename
            )
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(T.self, from: data) {
                return decoded
            }
            return nil
        } catch let error {
            LOG("[FileDatastore] Error reading data from \(filename) -> \(error)")
            return nil
        }
    }
    
    func deleteFileIfExists(at path: String) {
        guard fileExists(at: path) else { return }
        do {
            try deleteFile(at: path)
        } catch let error {
            LOG("[FileDataStore] Error deleting file at \(path) : \(error)", .error)
        }
    }
    func deleteFileIfExists(in directory: String, filename: String) {
        deleteFileIfExists(at: filePath(in: directory, filename: filename))
    }
    
    func rootDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(testEnv ? .documentDirectory : .applicationSupportDirectory, .userDomainMask, true)
        return (paths[0] as NSString).appendingPathComponent(testEnv ? "testData" : "")
    }
    
    
    // MARK: - Private
    @discardableResult
    internal func persist(data: Data, in directory: String, filename: String) throws -> String {
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        let path = filePath(in: directory, filename: filename)
        try persist(data: data, at: URL(fileURLWithPath: path))
        LOG("[FileDataStore] Data persisted to \(path)")
        return path
    }
    
    internal func data(from directory: String, filename: String) throws -> Data {
        let url = URL(fileURLWithPath: filePath(in: directory, filename: filename))
        return try data(at: url)
    }
    
    func persist(data: Data, at fileUrl: URL) throws {
        try data.write(to: fileUrl, options: [.atomic])
    }
    func data(at fileUrl: URL) throws -> Data {
        return try Data(contentsOf: fileUrl)
    }
    
    func filePath(in directory: String, filename: String) -> String {
        return (directory as NSString).appendingPathComponent(filename)
    }
    
    func hierarchyFromRootDirectory(directories: String...) -> String {
        var documentsDirectory = self.rootDirectory() as NSString
        directories.forEach { documentsDirectory = documentsDirectory.appendingPathComponent($0) as NSString }
        return documentsDirectory as String
    }
    
    func fileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    internal func fileExists(in directory: String, filename: String) -> Bool {
        return fileExists(at: filePath(in: directory, filename: filename))
    }
    
    private func deleteFile(at path: String) throws {
        try FileManager.default.removeItem(atPath: path)
    }
    private func deleteFile(from directory: String, filename: String) throws {
        try deleteFile(at: filePath(in: directory, filename: filename))
    }
}

extension FileDataStore: EngineComponent {
    func onLogoutUser() {
        
    }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) {
        
    }
}

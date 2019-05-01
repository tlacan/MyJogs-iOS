//
//  RemoteImageDataStore.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

class RemoteImageDataStore: NSObject {
    
    let dataStore: FileDataStore
    
    let cache = NSCache<NSString, AnyObject>()
    let imageService: ImageService
    
    init(imageService: ImageService, dataStore: FileDataStore) {
        self.imageService = imageService
        self.dataStore = dataStore
        super.init()
        
        try? FileManager.default.createDirectory(atPath: cacheDirectory(), withIntermediateDirectories: true, attributes: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMemoryWarningReceived),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        purgeExpiredCachedFiles()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onMemoryWarningReceived() {
        LOG("[RemoteImageDataStore] onMemoryWarningReceived, deleting cache")
        cache.removeAllObjects()
    }
    
    func cacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return (paths[0] as NSString).appendingPathComponent("images")
    }
    
    func filePathFromCache(fileName: String) -> String {
        return (cacheDirectory() as NSString).appendingPathComponent(fileName)
    }
    
    func purgeExpiredCachedFiles() {
        let directory = cacheDirectory()
        
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)
        let enumerator = FileManager.default.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles],
            errorHandler: { (_, error) -> Bool in
                LOG("[RemoteImageDataStore]  Error deleting old files \(directory)\(error)", .error)
                return true
        })
        let limitDate = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30days
        while let url = enumerator?.nextObject() as? URL {
            if  let resources = try? url.resourceValues(forKeys: [.creationDateKey]),
                let creationDate = resources.creationDate {
                if creationDate < limitDate {
                    do {
                        try FileManager.default.removeItem(at: url)
                        LOG("[RemoteImageDataStore]  Cleaned file at \(url)", .info)
                    } catch let error {
                        LOG("[RemoteImageDataStore]  Error deleting files at \(url)\(error)", .error)
                    }
                } else {
                    LOG("[RemoteImageDataStore]  Cache still valid for \(url)", .info)
                }
            } else {
                LOG("[RemoteImageDataStore]  Error while getting creation date for fileurl \(url)")
            }
        }
    }
    
    func image(for productURL: URL, completionHandler: @escaping (_ image: UIImage?, _ url: URL) -> Void) {
        imageForUrl(productURL) { (image, _) in
            completionHandler(image, productURL)
        }
    }
    
    @objc func imageForUrl(_ url: URL, completionHandler: @escaping (_ image: UIImage?, _ url: URL) -> Void) {
        
        let urlHash = url.absoluteString.sha256()
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            let data: NSData? = strongSelf.cache.object(forKey: urlHash as NSString) as? NSData
            
            // get image from nscache if possible
            if let goodData = data {
                let image = UIImage(data: goodData as Data)
                DispatchQueue.main.async {
                    LOG("[RemoteImageDataStore] Returning image at \(url) from cache")
                    completionHandler(image, url)
                }
                return
            }
            
            // check image available on disk
            let cacheFilePath = strongSelf.filePathFromCache(fileName: urlHash)
            if strongSelf.dataStore.fileExists(at: cacheFilePath) {
                if let data = try? strongSelf.dataStore.data(at: URL(fileURLWithPath: cacheFilePath)) {
                    DispatchQueue.main.async {
                        LOG("[RemoteImageDataStore] Returning image at \(url) from disk")
                        completionHandler(UIImage(data: data), url)
                    }
                    strongSelf.cache.setObject(data as AnyObject, forKey: urlHash as NSString)
                    return
                }
                strongSelf.dataStore.deleteFileIfExists(at: cacheFilePath)
            }
            
            // download image
            strongSelf.imageService.getImage(url: url, onDone: { [weak self] (data, image, error) in
                guard let strongSelf = self else { return }
                guard error == nil, let data = data, let image = image else {
                    completionHandler(nil, url)
                    return
                }
                
                DispatchQueue.main.async {
                    LOG("[RemoteImageDataStore] Returning image at \(url) from network")
                    completionHandler(image, url)
                }
                strongSelf.cache.setObject(data as AnyObject, forKey: urlHash as NSString)
                do {
                    try strongSelf.dataStore.persist(data: data, at: URL(fileURLWithPath: cacheFilePath))
                } catch let error {
                    LOG("[RemoteImageDataStore]  Error persisting \(urlHash) mathing url \(url.absoluteString) \(error)", .error)
                }
            })
        }
    }
}

extension RemoteImageDataStore: EngineComponent {
    func onLogoutUser() { }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) { }
}

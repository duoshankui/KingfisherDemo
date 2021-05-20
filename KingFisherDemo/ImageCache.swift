//
//  ImageCache.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/18.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

/// ImageCache represents both the memory and disk cache
class ImageCache {
    
    ///Memory
    fileprivate let memoryCache = NSCache<NSString, AnyObject>()
    
    /// Disk
    fileprivate let ioQueue: DispatchQueue
    fileprivate var fileManager: FileManager!
    
    public let diskCachePath: String
    
    public static let `defalut` = ImageCache(name: "default")
    
    private class func diskCachePathClosure(path: String?, cacheName: String) -> String {
        let dstPath = path ?? NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return (dstPath as NSString).appendingPathComponent(cacheName)
    }
    
    public init(name: String, path: String? = nil) {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the cache. A cache with empty name is not permitted")
        }
        
        let cacheName = "com.doublek.Kingfisher.ImageCache.\(name)"
        memoryCache.name = cacheName
        
        diskCachePath = ImageCache.diskCachePathClosure(path: path, cacheName: cacheName)
        
        let ioQueueName = "com.doublek.Kingfisher.ImageCache.ioQueue.\(name)"
        ioQueue = DispatchQueue(label: ioQueueName)
        
        
        
        ioQueue.sync { fileManager = FileManager() }
    }
    
    /// Store an image to cache. It will be saved to both memory and disk. It is an async operation
    open func store(_ image: UIImage,
                    original: Data? = nil,
                    forKey key: String,
                    processorIdentifier identifier: String = "",
                    cacheSerializer serializer: CacheSerializer = DefaultCacheSerializer.default,
                    toDisk: Bool = true,
                    completionHandler: (() -> Void)? = nil) {
        let computedKey = key.computedKey(with: identifier)
        /// 存储到缓存中
        memoryCache.setObject(image, forKey: computedKey as NSString, cost: image.kf.imageCost)
        
        
        func callHandlerInMainQueue () {
            if let handler = completionHandler {
                DispatchQueue.main.async {
                    handler()
                }
            }
        }
        
        if toDisk {
            /// 存储到磁盘中
            ioQueue.async {
                if let data = serializer.data(with: image, original: original) {
                    if !self.fileManager.fileExists(atPath: self.diskCachePath) {
                        do {
                            try self.fileManager.createDirectory(atPath: self.diskCachePath, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            
                        }
                    }
                    self.fileManager.createFile(atPath: self.cachePath(forComputedKey: computedKey), contents: data, attributes: nil)
                }
                callHandlerInMainQueue()
            }
        } else {
            callHandlerInMainQueue()
        }
    }
    
}

extension ImageCache {
    func cachePath(forComputedKey key: String) -> String {
        let fileName = cacheFileName(forComputedKey: key)
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
    
    func cacheFileName(forComputedKey key: String) -> String {
        return key.md5
    }
}

extension KingFisher where Base: UIImage {
    /// 缓存图片的花费成本
    var imageCost: Int {
        if base.images == nil {
            return Int(base.size.width * base.size.height * base.scale * base.scale)
        } else {
            return Int(base.size.width * base.size.height * base.scale * base.scale) * base.images!.count
        }
    }
}

extension String {
    func computedKey(with identifier: String) -> String {
        if identifier.isEmpty {
            return self
        } else {
            return appending("@\(identifier)")
        }
    }
}

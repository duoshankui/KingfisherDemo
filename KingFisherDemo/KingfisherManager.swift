//
//  KingfisherManager.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/18.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

typealias DownloadProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)
typealias CompletionHandler = ((_ image: UIImage?, _ error: NSError?, _ imageUrl: URL?) -> Void)

final class RetrieveImageTask {
    static let empty = RetrieveImageTask()
}

public let KingfisherErrorDomain = "com.doublek.Kingfisher.Error"

class KingfisherManager {
    static let shared = KingfisherManager()
    
    var cache: ImageCache
    var downloader: ImageDownloader
    
    convenience init() {
        self.init(downloader: .default, cache: .defalut)
    }
    
    init(downloader: ImageDownloader, cache: ImageCache) {
        self.downloader = downloader
        self.cache = cache
    }
    
    func retrieveImage(with resource: Resource,
                       options: KingfisherOptionsInfo?,
                       completionHandler: CompletionHandler?) -> RetrieveImageTask
    {
        let task = RetrieveImageTask()
        
        let options = options ?? KingfisherEmptyOptionsInfo
        
//        _ = downloadAndCacheImage(
//            with: resource.downloadUrl,
//            forKey: resource.cacheKey,
//            retrieveImageTask: task,
//            completionHandler: completionHandler,
//            options: options)

        if options.forceRefresh {
            _ = downloadAndCacheImage(
                with: resource.downloadUrl,
                forKey: resource.cacheKey,
                retrieveImageTask: task,
                completionHandler: completionHandler,
                options: options)
        } else {
            /// 先检索缓存
            tryToRetrieveImageFromCache(forKey: resource.cacheKey,
                                        with: resource.downloadUrl,
                                        retrieveTask: task,
                                        progressBlock: nil,
                                        completionHandler: completionHandler,
                                        options: options)
        }
        return task
    }
    
    @discardableResult
    func downloadAndCacheImage(with url: URL,
                               forKey key: String,
                               retrieveImageTask: RetrieveImageTask,
                               completionHandler: CompletionHandler?,
                               options: KingfisherOptionsInfo) -> RetrieveImageDownloadTask?
    {
        let downloader = self.downloader
        
        return downloader.downloadImage(
            with: url,
            retrieveImageTask: retrieveImageTask,
            completionHandler: { image, error, imageUrl, originData in
                
                let targetCache = self.cache
                if let error = error, error.code == 304 {
                    return
                }
                
                if let image = image, let originData = originData {
                    targetCache.store(image,
                                      original: originData,
                                      forKey: key,
                                      processorIdentifier: options.processor.identifier,
                                      cacheSerializer: options.cacheSerializer,
                                      completionHandler: {
                                        guard options.waitForCache else { return }
                                        
                                        completionHandler?(image, nil, url)
                                        
                                      })
                }
                
                if options.waitForCache == false || image == nil {
                    completionHandler?(image, error, imageUrl)
                }
        })
    }
    
    func tryToRetrieveImageFromCache(forKey key: String,
                                     with url: URL,
                                     retrieveTask: RetrieveImageTask,
                                     progressBlock: DownloadProgressBlock? = nil,
                                     completionHandler: CompletionHandler? = nil,
                                     options: KingfisherOptionsInfo)
    {
        let diskTaskCompletionHandler: CompletionHandler = {image, error, imageUrl in
            completionHandler?(image, error, imageUrl)
        }
        
        func handlerNoCache() {
            if options.onlyFromCache {
                let error = NSError(domain: KingfisherErrorDomain,
                                    code: KingfisherError.notCached.rawValue,
                                    userInfo: nil)
                diskTaskCompletionHandler(nil, error, url)
                return
            }
            
            self.downloadAndCacheImage(with: url,
                                       forKey: key,
                                       retrieveImageTask: retrieveTask,
                                       completionHandler: completionHandler,
                                       options: options)
        }
        
        let targetCache = self.cache
        
        targetCache.retrieveImage(forKey: key, options: options) { (image, cacheType) in
            
            /// 从缓存里获取到图片，结束
            if image != nil {
                diskTaskCompletionHandler(image, nil, url)
                return
            }
            
            /// 缓存里没有图片，去下载
            let processor = options.processor
            guard processor != DefaultImageProcessor.default else {
                handlerNoCache()
                return
            }
        }
    }
}

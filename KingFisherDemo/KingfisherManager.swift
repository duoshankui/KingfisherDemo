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
        
        _ = downloadAndCacheImage(
            with: resource.downloadUrl,
            forKey: resource.cacheKey,
            retrieveImageTask: task,
            completionHandler: completionHandler,
            options: options)

//        if options.forceRefresh {
//            _ = downloadAndCacheImage(
//                with: resource.downloadUrl,
//                forKey: resource.cacheKey,
//                retrieveImageTask: task,
//                completionHandler: completionHandler,
//                options: options)
//        } else {
//            /// 先检索缓存
//        }
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
    
}

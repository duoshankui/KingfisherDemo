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
        self.init(downloader: .default, cache: ImageCache())
    }
    
    init(downloader: ImageDownloader, cache: ImageCache) {
        self.downloader = downloader
        self.cache = cache
    }
    
    func retrieveImage(with resource: Resource, completionHandler: CompletionHandler?) -> RetrieveImageTask {
        let task = RetrieveImageTask()
        
        _ = downloadAndCacheImage(
            with: resource.downloadUrl,
            forKey: resource.cacheKey,
            retrieveImageTask: task,
            completionHandler: completionHandler)
        
        return task
    }
    
    @discardableResult
    func downloadAndCacheImage(with url: URL,
                               forKey key: String,
                               retrieveImageTask: RetrieveImageTask,
                               completionHandler: CompletionHandler?) -> RetrieveImageDownloadTask?
    {
        let downloader = self.downloader
        
        return downloader.downloadImage(
            with: url,
            retrieveImageTask: retrieveImageTask,
            completionHandler: { image, error, imageUrl, originData in
                completionHandler?(image, error, imageUrl)
        })
    }
    
}

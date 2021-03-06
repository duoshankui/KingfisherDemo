//
//  ImageDownload.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/18.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

typealias ImageDownloadProgressBlock = DownloadProgressBlock
/// Completion block of downloader
typealias ImageDownloaderCompletionHandler = ((_ image: UIImage?, _ error: NSError?, _ url: URL?, _ originalData: Data?) -> Void)


/// Download task.
struct RetrieveImageDownloadTask {
    let internalTask: URLSessionDataTask
    
    public private(set) weak var ownerDownloader: ImageDownloader?
}

public enum KingfisherError: Int {
    /// badData: The downloaded data is not an image or the data is corrupted.
    case badData = 10000
    /// notModified: The remote server responded a 304 code. No image data downloaded.
    case notModified = 10001
    case invalidStatusCode = 10002
    case notCached = 10003
}

public let KingfisherErrorStatusCodeKey = "statusCode"
protocol ImageDownloaderDelegate: AnyObject {
    func isValidStatusCode(_ code: Int, for downloader: ImageDownloader) -> Bool
}

extension ImageDownloaderDelegate {
    func isValidStatusCode(_ code: Int, for downloader: ImageDownloader) -> Bool {
        return (200..<400).contains(code)
    }
}

class ImageDownloader {
    
    class ImageFetchLoad {
        var contents = [(callback: CallbackPair, options: KingfisherOptionsInfo)]()
        var responseData = NSMutableData()
        
        var downloadTaskCount = 0
        var downloadTask: RetrieveImageDownloadTask?
        var cancelSemaphore: DispatchSemaphore?
    }
    
    
    open var downloadTimer: TimeInterval = 15.0
    
    weak var delegate: ImageDownloaderDelegate?
    
    fileprivate let sessionHandler: ImageDownloadSessionHandler
    fileprivate let session: URLSession?
    
    // MARK: - Internal property
    let barrierQueue: DispatchQueue
    let processQueue: DispatchQueue
    
    typealias CallbackPair = ((progressBlock: ImageDownloadProgressBlock?, completionHandler: ImageDownloaderCompletionHandler?))
    var fetchLoads = [URL: ImageFetchLoad]()
    
    public static let `default` = ImageDownloader(name: "default")
    
    
    init(name: String) {
        if name.isEmpty {
            fatalError("[Kingfisher] You should specify a name for the downloader. A downloader with empty name is not permitted")
        }
        
        /// 创建并行队列
        barrierQueue = DispatchQueue(label: "com.doublek.Kingfisher.ImageDownloader.Barrier.\(name)", attributes: .concurrent)
        
        processQueue = DispatchQueue(label: "com.doublek.Kingfisher.ImageDownloader.Process.\(name)", attributes: .concurrent)
        
        sessionHandler = ImageDownloadSessionHandler(name: name)
        session = URLSession(configuration: .ephemeral, delegate: sessionHandler, delegateQueue: OperationQueue.main)
    }
    
    deinit {
        session?.invalidateAndCancel()
    }

    func fetchLoad(with url: URL) -> ImageFetchLoad? {
        var fetchLoad: ImageFetchLoad?
        barrierQueue.sync(flags: .barrier) {
            fetchLoad = fetchLoads[url]
        }
        return fetchLoad
    }
    
    @discardableResult
    func downloadImage(with url: URL,
                       retrieveImageTask: RetrieveImageTask? = nil,
                       completionHandler: ImageDownloaderCompletionHandler? = nil) -> RetrieveImageDownloadTask?
    {
        var downloadTask: RetrieveImageDownloadTask?
        
        let timeout = self.downloadTimer == 0.0 ? 15.0 : self.downloadTimer
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpShouldUsePipelining = false
        
        setup(progressBlock: nil, with: completionHandler, for: url) { (session, fetchLoad) in
            if fetchLoad.downloadTask == nil {
                let dataTask = session.dataTask(with: request)
                fetchLoad.downloadTask = RetrieveImageDownloadTask(internalTask: dataTask, ownerDownloader: self)
                dataTask.priority = URLSessionTask.defaultPriority
                dataTask.resume()
                
                self.sessionHandler.downloadHolder = self
            }
            
            fetchLoad.downloadTaskCount += 1
            downloadTask = fetchLoad.downloadTask
        }
        
        return downloadTask
    }
    
}

extension ImageDownloader {
    func setup(progressBlock: ImageDownloadProgressBlock?, with completionHandler: ImageDownloaderCompletionHandler?, for url: URL, started: @escaping ((URLSession, ImageFetchLoad) -> Void)) {
        
        func prepareFetchLoad() {
            /// 栅栏函数  并行同步 保证前面的任务执行完后再执行后面的任务
            barrierQueue.sync(flags: .barrier) {
                let loadObjectForURL = fetchLoads[url] ?? ImageFetchLoad()
                let callbackPair = (progressBlock: progressBlock, completionHandler: completionHandler)
                loadObjectForURL.contents.append((callbackPair, KingfisherEmptyOptionsInfo))
                fetchLoads[url] = loadObjectForURL
                
                if let session = session {
                    started(session, loadObjectForURL)
                }
            }
        }
        
        if let fetchLoad = fetchLoad(with: url), fetchLoad.downloadTaskCount == 0  {
            
        } else {
            prepareFetchLoad()
        }
    }
}

extension ImageDownloader: ImageDownloaderDelegate {}

final class ImageDownloadSessionHandler: NSObject, URLSessionDataDelegate {
    
    private let downloaderQueue: DispatchQueue
    
    private var _downloadHolder: ImageDownloader?
    var downloadHolder: ImageDownloader? {
        get {
            return downloaderQueue.sync { _downloadHolder }
        }
        set {
            downloaderQueue.sync { _downloadHolder = newValue }
        }
    }
    
    init(name: String) {
        /// 串行队列
        downloaderQueue = DispatchQueue(label: "com.doublek.Kingfisher.ImageDownloader.SessionHandler.\(name)")
        /// 并行队列  attributes 不指定的情况下为串行队列
//        downloaderQueue = DispatchQueue(label: "com.doublek.concurrent", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
        super.init()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {        
        
        guard let downloader = self.downloadHolder else {
            completionHandler(.cancel)
            return
        }
        
        var disposition = URLSession.ResponseDisposition.allow

        if let statusCode = (response as? HTTPURLResponse)?.statusCode,
           let url = dataTask.originalRequest?.url,
           !(downloader.delegate ?? downloader).isValidStatusCode(statusCode, for: downloader) {
            let error = NSError(domain: KingfisherErrorDomain,
                                code: KingfisherError.invalidStatusCode.rawValue,
                                userInfo: [KingfisherErrorStatusCodeKey: statusCode])
            
            callCompletionHandlerFailure(error: error, url: url)
            disposition = .cancel
        }
        
        completionHandler(disposition)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let downloader = downloadHolder else { return }
        if let url = dataTask.originalRequest?.url, let fetchLoad = downloader.fetchLoad(with: url) {
            fetchLoad.responseData.append(data)
            
            if let expectedLength = dataTask.response?.expectedContentLength {
                for content in fetchLoad.contents {
                    DispatchQueue.main.async {
                        content.callback.progressBlock?(Int64(fetchLoad.responseData.length), expectedLength)
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.originalRequest?.url else { return }
        
        guard error == nil else {
            callCompletionHandlerFailure(error: error!, url: url)
            return
        }
        
        processImage(for: task, url: url)
    }
    
    private func clearFetchLoad(with url: URL) {
        guard let downloader = downloadHolder else { return }
        
        downloader.barrierQueue.sync(flags: .barrier) {
            downloader.fetchLoads.removeValue(forKey: url)
            if downloader.fetchLoads.isEmpty {
                downloadHolder = nil
            }
        }
    }
    
    private func callCompletionHandlerFailure(error: Error, url: URL) {
        guard let downloder = self.downloadHolder, let fetchloader = downloder.fetchLoad(with: url) else {
            return
        }
        clearFetchLoad(with: url)
        var leftSignal: Int
        repeat {
            leftSignal = fetchloader.cancelSemaphore?.signal() ?? 0
        } while leftSignal != 0
        
        for content in fetchloader.contents {
            content.options.callbackDispatchQueue.async {
                content.callback.completionHandler?(nil, error as NSError, url, nil)
            }
        }
    }
    
    private func processImage(for task: URLSessionTask, url: URL) {
        guard let downloader = downloadHolder else { return }
        
        downloader.processQueue.async {
            guard let fetchLoad = downloader.fetchLoad(with: url) else { return }
            self.clearFetchLoad(with: url)
            
            let data: Data? = fetchLoad.responseData as Data

            // Cache the processed images. So we do not need to re-process the image if using the same processor.
            var imageCache = [String: UIImage]()
            for content in fetchLoad.contents {
                let options = content.options
                let completionHandler = content.callback.completionHandler
                let callbackQueue = options.callbackDispatchQueue
                
                let processor = options.processor
                
                var image = imageCache[processor.identifier]
                if let data = data, image == nil {
                    image = processor.process(item: .data(data), options: options)
                    imageCache[processor.identifier] = image
                }
                
                if let image = image {
                    let imageModifier = options.imageModifier
                    let finalImage = imageModifier.modify(image)
                    callbackQueue.safeAsync {
                        completionHandler?(finalImage, nil, url, data)
                    }
                } else {
                    if let res = task.response as? HTTPURLResponse, res.statusCode == 304 {
                        let notModified = NSError(domain: KingfisherErrorDomain, code: KingfisherError.notModified.rawValue, userInfo: nil)
                        completionHandler?(nil, notModified, url, nil)
                        return
                    }
                    
                    let badData = NSError(domain: KingfisherErrorDomain, code: KingfisherError.badData.rawValue, userInfo: nil)
                    callbackQueue.safeAsync {
                        completionHandler?(nil, badData, url, nil)
                    }
                }
            }
        }
        
    }
}

//
//  CacheSeriallizer.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/20.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

public protocol CacheSerializer {
    func data(with image: UIImage, original: Data?) -> Data?
    func image(with data: Data, options: KingfisherOptionsInfo?) -> UIImage?
}

public struct DefaultCacheSerializer: CacheSerializer {
    
    public static let `default` = DefaultCacheSerializer()
    private init() {}
    
    
    public func data(with image: UIImage, original: Data?) -> Data? {
        
        let imageFormat = original?.kf.imageFormat ?? .unknown
        let data: Data?
        switch imageFormat {
        case .PNG:
            data = image.pngData()
        case .JPEG:
            data = image.jpegData(compressionQuality: 1.0)
        case .GIF:
            return original
        case .unknown:
            data = original
        }
        return data
    }
    
    public func image(with data: Data, options: KingfisherOptionsInfo?) -> UIImage? {
        let options = options ?? KingfisherEmptyOptionsInfo
        return KingFisher<UIImage>.image(data: data, scale: options.scaleFactor)
    }
}

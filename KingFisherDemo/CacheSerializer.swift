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
}

public struct DefaultCacheSerializer: CacheSerializer {
    
    public static let `default` = DefaultCacheSerializer()
    private init() {}
    
    
    public func data(with image: UIImage, original: Data?) -> Data? {
        
        let imageFormat = ImageFormat.unknown
        let data: Data?
        switch imageFormat {
        case .PNG:
            return original
        case .JPEG:
            return original
        case .GIF:
            return original
        case .unknown:
            data = original
        }
        return data
    }
}

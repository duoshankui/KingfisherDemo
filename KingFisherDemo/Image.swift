//
//  Image.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/20.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

extension KingFisher where Base: UIImage {
    
    public static func image(data: Data, scale: CGFloat) -> UIImage? {
        
        var image: UIImage?
        
        switch data.kf.imageFormat {
        case .PNG:
            image = UIImage(data: data, scale: scale)
        case .JPEG:
            image = UIImage(data: data, scale: scale)
        default:
            image = UIImage(data: data, scale: scale)
        }
        return image
    }
}

private struct ImageHeaderData {
    static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
    static var JPEG_IF: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47, 0x49, 0x46]
}

public enum ImageFormat {
    case unknown, PNG, JPEG, GIF
}

public struct DataProxy {
    fileprivate let base: Data
    init(proxy: Data) {
        self.base = proxy
    }
}

extension Data: KingFisherCompatible {
    public var kf: DataProxy {
        return DataProxy(proxy: self)
    }
    public typealias CompatibleType = DataProxy
}

extension DataProxy {
    public var imageFormat: ImageFormat {
        var buffer = [UInt8](repeating: 0, count: 8)
        (base as NSData).getBytes(&buffer, length: 8)
        
        if buffer == ImageHeaderData.PNG {
            return .PNG
        } else if buffer[0] == ImageHeaderData.JPEG_SOI[0] &&
            buffer[1] == ImageHeaderData.JPEG_SOI[1] &&
            buffer[2] == ImageHeaderData.JPEG_IF[0]
        {
            return .JPEG
        } else {
            return .unknown
        }
    }
}

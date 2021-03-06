//
//  ImageProcessor.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/18.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

public enum ProcessImageItem {
    case image(UIImage)
    case data(Data)
}

/// An `ImageProcessor` would be used to convert some downloaded data to an image.
public protocol ImageProcessor {
    var identifier: String { get }
    
    func process(item: ProcessImageItem, options: KingfisherOptionsInfo) -> UIImage?
}

func ==(left: ImageProcessor, right: ImageProcessor) -> Bool {
    return left.identifier == right.identifier
}

func !=(left: ImageProcessor, right: ImageProcessor) -> Bool {
    return !(left == right)
}

public struct DefaultImageProcessor: ImageProcessor {
    
    public static let `default` = DefaultImageProcessor()
    
    public let identifier: String = ""
    
    public init() {}
    
    public func process(item: ProcessImageItem, options: KingfisherOptionsInfo) -> UIImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            return KingFisher<UIImage>.image(data: data, scale: options.scaleFactor)
        }
    }
}

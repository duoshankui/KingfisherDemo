//
//  ImageModifier.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/24.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

public protocol ImageModifier {
    func modify(_ image: UIImage) -> UIImage
}

public struct DefaultImageModifier: ImageModifier {
    
    public static let `default` = DefaultImageModifier()
    
    public init() {}
    
    public func modify(_ image: UIImage) -> UIImage {
        return image
    }
}

//
//  KingfisherOptionsInfo.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/18.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation

public typealias KingfisherOptionsInfo = [KingfisherOptionsInfoItem]
let KingfisherEmptyOptionsInfo = [KingfisherOptionsInfoItem]()
public enum KingfisherOptionsInfoItem {
    
}


extension Collection where Iterator.Element == KingfisherOptionsInfoItem {
    public var processor: ImageProcessor {
        return DefaultImageProcessor.default
    }
    
    public var callbackDispatchQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
}

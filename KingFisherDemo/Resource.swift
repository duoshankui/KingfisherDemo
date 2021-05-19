//
//  Resource.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/17.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation

protocol Resource {
    var cacheKey: String { get}
    var downloadUrl: URL { get }
}

extension URL: Resource {
    var downloadUrl: URL {
        return self
    }
    
    var cacheKey: String {
        return absoluteString
    }
    
}

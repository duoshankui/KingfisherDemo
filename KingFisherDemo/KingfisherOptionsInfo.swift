//
//  KingfisherOptionsInfo.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/18.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

public typealias KingfisherOptionsInfo = [KingfisherOptionsInfoItem]
let KingfisherEmptyOptionsInfo = [KingfisherOptionsInfoItem]()
public enum KingfisherOptionsInfoItem {
    case forceRefresh
    /// 是否等待缓存操作
    case waitForCache
    case fromMemoryCacheOrRefresh
    case onlyFromCache
}

/**
 associativity：多个运算符放一起，是从左算到右，还是从右算到左的差别
 none：代表没有结合性
 比如 a1 + a2 + a3，加号的默认结合性为从左到右，先算 a1 + a2，再算 + a3。
 如果为none，不允许连续出现，只能一个加法存在
 
 higherThan：比谁的优先级高
 lowerThan：比谁的优先级低
 */
/// 优先级组
precedencegroup CustomOperator {
    ///结合性(left\right\none)
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

/**
 prefix operator 前缀运算符
 postfix operator 后缀运算符
 infix operator 中缀运算符：优先级组
 */
/// 自定义运算符<==
infix operator <== : CustomOperator
func <== (lhs: KingfisherOptionsInfoItem, rhs: KingfisherOptionsInfoItem) -> Bool {
    switch (lhs, rhs) {
    case (.forceRefresh, .forceRefresh): return true
    case (.waitForCache, .waitForCache): return true
    case (.fromMemoryCacheOrRefresh, .fromMemoryCacheOrRefresh): return true
    case (.onlyFromCache, .onlyFromCache): return true
    default: return false
    }
}

extension Collection where Iterator.Element == KingfisherOptionsInfoItem {
    
    public var forceRefresh: Bool {
        return contains { $0 <== .forceRefresh }
    }
    
    public var waitForCache: Bool {
        return contains { $0 <== .waitForCache }
    }
    
    public var fromMemoryCacheOrRefresh: Bool {
        return contains { $0 <== .fromMemoryCacheOrRefresh }
    }
    
    public var onlyFromCache: Bool {
        return contains { $0 <== .onlyFromCache }
    }
    
    public var processor: ImageProcessor {
        return DefaultImageProcessor.default
    }
    
    public var imageModifier: ImageModifier {
        return DefaultImageModifier.default
    }
    
    public var cacheSerializer: CacheSerializer {
        return DefaultCacheSerializer.default
    }
    
    public var callbackDispatchQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
}

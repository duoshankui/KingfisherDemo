//
//  KingFisher.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2020/6/2.
//  Copyright © 2020 DoubleK. All rights reserved.
//

import Foundation
import UIKit

public final class KingFisher<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}


public protocol KingFisherCompatible {
//    associatedtype CompatibleType
//    /// 只读
//    var kf: CompatibleType { get }
}

public extension KingFisherCompatible {
    var kf: KingFisher<Self> {
        return KingFisher(self)
    }
}

extension UIImageView: KingFisherCompatible { }
extension UIButton: KingFisherCompatible { } 

//
//  Runtime.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/17.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation

func getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}


func setRetainedAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, _ value: T?) {
    objc_setAssociatedObject(object, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

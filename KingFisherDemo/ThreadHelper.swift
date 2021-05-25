//
//  ThreadHelper.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/25.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation

extension DispatchQueue {
    func safeAsync(_ block: @escaping ()->Void) {
        if self == DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}

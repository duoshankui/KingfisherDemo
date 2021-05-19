//
//  Placeholder.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/17.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import UIKit

protocol Placeholder {
    func add(to imageView: UIImageView)
    func remove(from imageView: UIImageView)
}

extension Placeholder where Self: UIImage {
    func add(to imageView: UIImageView) {
        imageView.image = self
    }
    
    func remove(from imageView: UIImageView) {
        imageView.image = nil
    }
}

extension UIImage: Placeholder {}

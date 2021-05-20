//
//  UIImageView + KingFisher.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2020/6/2.
//  Copyright © 2020 DoubleK. All rights reserved.
//

import Foundation
import UIKit


extension KingFisher where Base: UIImageView {
    
    @discardableResult
    func setImage(with resource: Resource?,
                  placeholder: Placeholder? = nil,
                  options: KingfisherOptionsInfo? = nil) -> RetrieveImageTask
    {
        guard let resource = resource else {
            self.placeholder = placeholder
            setWebURL(nil)
            return .empty
        }
        
        setWebURL(resource.downloadUrl)
        let task = KingfisherManager.shared.retrieveImage(with: resource, options: options, completionHandler: {[weak base] image, error, imageUrl in
            DispatchQueue.main.async {
                
                guard let strongBase = base, imageUrl == self.webURL else {
                    return
                }
                
                self.setImageTask(nil)
                guard let image = image else { return }
                
                self.placeholder = nil
                strongBase.image = image
            }
        })
        setImageTask(task)
        return task
    }
}

private var placeholderKey: Void?
private var lastURLKey: Void?
private var imageTaskKey: Void?
extension KingFisher where Base: UIImageView {
    
    var webURL: URL? {
        return objc_getAssociatedObject(base, &lastURLKey) as? URL
    }
    
    func setWebURL(_ url: URL?) {
        objc_setAssociatedObject(base, &lastURLKey, url, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    
    fileprivate var imageTask: RetrieveImageTask? {
        return objc_getAssociatedObject(base, &imageTaskKey) as? RetrieveImageTask
    }
    
    fileprivate func setImageTask(_ task: RetrieveImageTask?) {
        objc_setAssociatedObject(base, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var placeholder: Placeholder? {
        get {
            return objc_getAssociatedObject(base, &placeholderKey) as? Placeholder
        }
        set {
            if let previousPlaceholder = placeholder {
                previousPlaceholder.remove(from: base)
            }
            
            if let newPlaceholder = newValue {
                newPlaceholder.add(to: base)
            } else {
                base.image = nil
            }
            objc_setAssociatedObject(base, &placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


extension KingFisher where Base: UIButton {
    
    @discardableResult
    func setBtnImage(with Resouce: URL?) -> UIImage {
        return UIImage()
    }
}

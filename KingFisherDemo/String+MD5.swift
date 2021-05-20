//
//  String+MD5.swift
//  KingFisherDemo
//
//  Created by DoubleK on 2021/5/20.
//  Copyright © 2021 DoubleK. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    public var md5: String {
        guard let data = self.data(using: .utf8, allowLossyConversion: true) else {
            return self
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        #if swift(>=5.0)
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        #else
        _ = data.withUnsafeBytes { bytes in
            return CC_MD5(bytes, CC_LONG(data.count), &digest)
        }
        #endif
        
        return digest.reduce(into: "") { $0 += String(format: "%02x", $1) }
    }
}

//
//  Int+HIDUtil.swift
//  HIDUtil
//
//  Created by James Linnell on 11/14/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation
import SwiftyHID

extension UInt8 {
	var hexString: String {
		return String(format: "%02x", self)
	}
}

extension FixedWidthInteger {
	var hexString: String {
		var bytes: [UInt8] = []
		for i in 0..<self.bitWidth / 8 {
			bytes.append(UInt8((self & Self(0xff << (i*8))) >> Self(i*8)))
		}
		return bytes.map { String(format: "%02x ", $0)}.joined()
	}
}

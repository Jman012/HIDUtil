//
//  Data+HIDUtil.swift
//  HIDUtil
//
//  Created by James Linnell on 10/29/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation

extension Data {
	var hexString: String {
		return self.map { String(format: "%02x ", $0) }.joined()
	}
}

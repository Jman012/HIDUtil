//
//  DispatchSemaphore+Extensions.swift
//  HIDUtil
//
//  Created by James Linnell on 10/24/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation

extension DispatchSemaphore {
	func sync(_ block: () -> Void) {
		self.wait()
		block()
		self.signal()
	}
}

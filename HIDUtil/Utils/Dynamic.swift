//
//  Dynamic.swift
//  HIDUtil
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation

class Dynamic<T> {
	typealias Listener = (T) -> Void
	var listener: Listener?
	
	var value: T {
		didSet {
			listener?(value)
		}
	}
	
	init(_ v: T) {
		value = v
	}
	
	func bind(listener: Listener?) {
		self.listener = listener
	}
	
	func bindAndFire(listener: Listener?) {
		self.listener = listener
		listener?(value)
	}
	
	func fire() {
		listener?(value)
	}
}

//
//  OutlineViewRow.swift
//  HIDUtil
//
//  Created by James Linnell on 10/25/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation

class OutlineViewRow {
	let key: String
	let value: Any?
	let children: [OutlineViewRow]
	
	init(key: String, value: Any?, children: [OutlineViewRow]) {
		self.key = key
		self.value = value
		self.children = children
	}
}

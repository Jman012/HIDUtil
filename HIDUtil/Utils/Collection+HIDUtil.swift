//
//  Collection+HIDUtil.swift
//  HIDUtil
//
//  Created by James Linnell on 12/1/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation

extension Collection {
	
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

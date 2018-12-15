//
//  DeviceManagerViewModel.swift
//  HIDUtil
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation
import SwiftyHID

class DeviceManagerViewModel {
	
	var devices = Dynamic<[HIDDevice]>([])
	var manager: HIDManager!
	
	init() {
		manager = HIDManager.create(allocator: kCFAllocatorDefault, options: HIDOption.none)
		
		manager.setDeviceMatching(multiple: [
			[:]
		])
		
		manager.register(matchingCallback:  { (result, sender, device) in
			self.devices.value.append(device)
			self.devices.fire()
			print("\(device.product as Any), \(device.locationID as Any), \(device.vendorID as Any), \(device.productID as Any), \(device.maxInputReportSize as Any)")
		})
		
		manager.register(removalCallback: { (result, manager, device) in
			if let index = self.devices.value.index(of: device) {
				self.devices.value.remove(at: index)
				self.devices.fire()
			}
		})
		
		manager.schedule(with: CFRunLoopGetCurrent(), mode: CFRunLoopMode.defaultMode)
		_ = manager.open(with: .none)
	}
}

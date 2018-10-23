//
//  DeviceViewModel.swift
//  JoyConManager
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation
import SwiftyHID

class DeviceViewModel {
	
	// MARK: Dynamic Properties
	
	var reportDescriptor: Dynamic<Data> = Dynamic(Data())
	
	// MARK: Initialization
	
	var device: HIDDevice {
		didSet {
			refreshDevice()
		}
	}
	
	init(withDevice dev: HIDDevice) {
		device = dev
		refreshDevice()
	}
	
	private func refreshDevice() {
		reportDescriptor.value = device.reportDescriptor ?? Data()
	}
}

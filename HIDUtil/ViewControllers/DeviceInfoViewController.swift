//
//  DeviceInfoViewController.swift
//  JoyConManager
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa

class DeviceInfoViewController: NSViewController {
	@IBOutlet weak var rawDescriptorLabel: NSTextField!
	
	var deviceInfo: DeviceViewModel? {
		didSet {
			deviceInfo?.reportDescriptor.bindAndFire(listener: { [weak self] (reportDescriptor) in
				self?.rawDescriptorLabel.stringValue = reportDescriptor.map { String(format: "%02x ", $0) }.joined()
			})
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

//
//  DeviceInfoViewController.swift
//  JoyConManager
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa

class DeviceReportDescriptorViewController: NSViewController, DeviceViewModelable {
	@IBOutlet weak var rawDescriptorLabel: NSTextField!
	
	var deviceViewModel: DeviceViewModel? {
		didSet {
			deviceViewModel?.reportDescriptor.bindAndFire(listener: { [weak self] (reportDescriptor) in
				self?.rawDescriptorLabel.stringValue = reportDescriptor.map { String(format: "%02x ", $0) }.joined()
			})
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

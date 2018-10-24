//
//  DeviceReportsViewController.swift
//  HIDUtil
//
//  Created by James Linnell on 10/23/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa

class DeviceReportsViewController: NSViewController, DeviceViewModelable {

	@IBOutlet weak var outlineView: NSOutlineView!
	
	var deviceViewModel: DeviceViewModel? {
		didSet {
			
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
    }
}

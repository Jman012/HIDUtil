//
//  ViewController.swift
//  JoyConManager
//
//  Created by James Linnell on 9/9/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa
import IOKit
import SwiftyHID

protocol DeviceViewModelable {
	var deviceViewModel: DeviceViewModel? { get set }
}

class DeviceManagerViewController: NSViewController {

	@IBOutlet weak var deviceList: NSPopUpButton!
	@IBOutlet weak var deviceInfoView: NSView!
	
	var deviceManager: DeviceManagerViewModel? {
		didSet {
			deviceManager?.devices.bindAndFire { [weak self] (devices) in
				DispatchQueue.main.async {
					self?.updateDeviceList(devices)
				}
			}
		}
	}
	
	var deviceViewModel: DeviceViewModel?
	var tabs: [DeviceViewModelable] = []
	var deviceInfoVC: DeviceInfoViewController?
	var deviceReportDescriptorVC: DeviceReportDescriptorViewController?
	var deviceReportsVC: DeviceReportsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		deviceManager = DeviceManagerViewModel()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		if let vc = children.first(where: { $0 is DeviceInfoViewController }) as? DeviceInfoViewController {
			deviceInfoVC = vc
			tabs.append(vc)
		}
		if let vc = children.first(where: { $0 is DeviceReportDescriptorViewController }) as? DeviceReportDescriptorViewController {
			deviceReportDescriptorVC = vc
			tabs.append(vc)
		}
		if let vc = children.first(where: { $0 is DeviceReportsViewController }) as? DeviceReportsViewController {
			deviceReportsVC = vc
			tabs.append(vc)
		}
	}

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
	
	// MARK: View Callbacks
	
	@IBAction func deviceListDidChoose(_ sender: NSPopUpButton) {
		guard let device = deviceManager?.devices.value[sender.indexOfSelectedItem] else {
			return
		}
		
		for tab in tabs {
			if tab.deviceViewModel?.device != device {
				tab.deviceViewModel?.device = device
			}
		}
	}

	// MARK: Custom View Methods
	
	private func updateDeviceList(_ devices: [HIDDevice]) {
		deviceList.removeAllItems()
		let titles = devices.map {
			"\($0.product ?? "") (\($0.vendorID ?? 0), \($0.productID ?? 0), \($0.primaryUsage!.usagePage), \($0.primaryUsage!.usage))"
		}
		deviceList.addItems(withTitles: titles)
		
		if let dev = devices.first {
			// Set the DeviceViewModel on each tab
			if deviceViewModel == nil {
				deviceViewModel = DeviceViewModel(withDevice: dev)
				// They will share the same instance
				for var tab in tabs {
					tab.deviceViewModel = deviceViewModel
				}
			}
			
			deviceListDidChoose(deviceList)
		}
	}
	
}


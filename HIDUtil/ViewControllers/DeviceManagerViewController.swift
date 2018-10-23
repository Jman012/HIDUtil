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
	var deviceInfoController: DeviceInfoViewController! {
		return children.first(where: { vc in vc is DeviceInfoViewController }) as? DeviceInfoViewController
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		deviceManager = DeviceManagerViewModel()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
	
	// MARK: View Callbacks
	
	@IBAction func deviceListDidChoose(_ sender: NSPopUpButton) {
		// Don't re-set the device if not needed
		guard let device = deviceManager?.devices.value[sender.indexOfSelectedItem],
			device != deviceInfoController.deviceInfo?.device else {
				return
		}
		
		deviceInfoController.deviceInfo!.device = device
	}

	// MARK: Custom View Methods
	
	private func updateDeviceList(_ devices: [HIDDevice]) {
		deviceList.removeAllItems()
		let titles = devices.map {
			"\($0.product ?? "") (\($0.vendorID ?? 0), \($0.productID ?? 0), \($0.primaryUsage!.usagePage), \($0.primaryUsage!.usage))"
		}
		deviceList.addItems(withTitles: titles)
		
		if let dev = devices.first, deviceInfoController.deviceInfo == nil {
			deviceInfoController.deviceInfo = DeviceViewModel(withDevice: dev)
		}
		if devices.count > 0 {
			deviceListDidChoose(deviceList)
		}
	}
	
}


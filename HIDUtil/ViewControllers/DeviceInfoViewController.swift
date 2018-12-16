//
//  DeviceInfoViewController.swift
//  HIDUtil
//
//  Created by James Linnell on 12/8/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa
import SwiftyHID

class DeviceInfoViewController: NSViewController, DeviceViewModelable {
	
	var deviceViewModel: DeviceViewModel? {
		didSet {
			tableView.reloadData()
		}
	}
	
	@IBOutlet var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		tableView.dataSource = self
		tableView.delegate = self
    }
    
}

extension DeviceInfoViewController: NSTableViewDataSource {
	
	// MARK: NSTableViewDataSource Implementation
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return HIDDevicePropertyKey.allCases.count
	}
}

extension DeviceInfoViewController: NSTableViewDelegate {
	
	// MARK: NSTableViewDelegate Implementation
	
	fileprivate enum ColumnIdentifiers {
		static let KeyColumnID = NSUserInterfaceItemIdentifier("KeyColumnID")
		static let ValueColumnID = NSUserInterfaceItemIdentifier("ValueColumnID")
	}
	
	fileprivate enum CellIdentifiers {
		static let KeyCellID = NSUserInterfaceItemIdentifier("KeyCellID")
		static let ValueCellID = NSUserInterfaceItemIdentifier("ValueCellID")
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let tableColumn = tableColumn,
			let deviceViewModel = deviceViewModel,
			let hidDevicePropertyKey = HIDDevicePropertyKey.allCases[safe: row] else {
			return nil
		}
		
		let cellIdentifier: NSUserInterfaceItemIdentifier
		let text: String
		switch tableColumn.identifier {
		case ColumnIdentifiers.KeyColumnID:
			cellIdentifier = CellIdentifiers.KeyCellID
			text = hidDevicePropertyKey.key
			
		case ColumnIdentifiers.ValueColumnID:
			cellIdentifier = CellIdentifiers.ValueCellID
			if let val = deviceViewModel.device.getProperty(key: hidDevicePropertyKey) {
				text = "\(val)"
			} else {
				text = ""
			}
			
		default:
			return nil
		}
		
		if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = text
			return cell
		}
		
		return nil
	}
}

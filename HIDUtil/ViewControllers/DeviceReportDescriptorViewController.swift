//
//  DeviceInfoViewController.swift
//  HIDUtil
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa
import SwiftyHID

class DeviceReportDescriptorViewController: NSViewController, DeviceViewModelable {
	@IBOutlet weak var rawDescriptorLabel: NSTextField!
	@IBOutlet weak var tableView: NSTableView!
	
	var deviceViewModel: DeviceViewModel? {
		didSet {
			deviceViewModel?.reportDescriptor.bindAndFire(listener: { [weak self] (reportDescriptor) in
				self?.rawDescriptorLabel.stringValue = reportDescriptor.hexString
			})
			
			deviceViewModel?.lexedReportDescriptor.bindAndFire(listener: { [weak self] (lexedReportDescriptor) in
				self?.tableView.reloadData()
			})
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		tableView.dataSource = self
		tableView.delegate = self
    }
    
}

extension DeviceReportDescriptorViewController: NSTableViewDataSource {
	
	// MARK: NSTableViewDataSource Implementation
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return deviceViewModel?.lexedReportDescriptor.value.count ?? 0
	}
}

extension DeviceReportDescriptorViewController: NSTableViewDelegate {
	
	// MARK: NSTableViewDelegate Implementation
	
	fileprivate enum ColumnIdentifiers {
		static let DataColumn = "DataColumn"
		static let DescriptionColumn = "DescriptionColumn"
	}
	fileprivate enum CellIdentifiers {
		static let DataCell = "DataCellID"
		static let DescriptionCell = "DescriptionCellID"
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let tableColumn = tableColumn,
			let lexedDescriptorItem = deviceViewModel?.lexedReportDescriptor.value[safe: row] else {
			return nil
		}
		
		var cellIdentifier: String
		var text: String
		
		switch tableColumn.identifier.rawValue {
		case ColumnIdentifiers.DataColumn:
			cellIdentifier = CellIdentifiers.DataCell
			text = lexedDescriptorItem.descriptorData.header.hexString + " " + lexedDescriptorItem.descriptorData.bytes.hexString
			
		case ColumnIdentifiers.DescriptionColumn:
			cellIdentifier = CellIdentifiers.DescriptionCell
			var tabs: String = ""
			for _ in 0..<lexedDescriptorItem.tabIndex {
				tabs += "\t"
			}
			var desc = lexedDescriptorItem.descriptorItem.description
			if let overrideUsage = lexedDescriptorItem.overrideUsage {
				desc = "Usage (\(overrideUsage))"
			}
			text = tabs + desc
			
		default:
			return nil
		}
		
		if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView {
			cell.textField?.stringValue = text
			return cell
		}
		return nil
	}
}



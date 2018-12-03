//
//  DeviceReportsViewController.swift
//  HIDUtil
//
//  Created by James Linnell on 10/23/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Cocoa
import SwiftyHID

class DeviceReportsViewController: NSViewController, DeviceViewModelable {

	@IBOutlet weak var outlineView: NSOutlineView!
	
	private var deviceReports: [DeviceReport] = []
	private var deviceReportRows: [OutlineViewRow] = []
	
	var deviceViewModel: DeviceViewModel? {
		didSet {
			deviceViewModel?.deviceReports.bindAndFire(listener: { [weak self] (reports) in
				guard let self = self else { return }
				
				self.deviceReports = reports
				self.deviceReportRows = reports.map { OutlineViewRow(deviceReport: $0) }
				self.outlineView.reloadData()
			})
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		outlineView.dataSource = self
		outlineView.delegate = self
    }
}

extension DeviceReportsViewController: NSOutlineViewDataSource {
	
	// MARK: NSOutlineViewDataSource Implementation
	
	public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return deviceReportRows.count
		} else if let item = item as? OutlineViewRow, let value = item.value as? OutlineViewRow {
			return value.children.count
		} else if let item = item as? OutlineViewRow {
			return item.children.count
		}
		return 0
	}
	
	public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			return deviceReportRows[index]
		} else if let item = item as? OutlineViewRow, let value = item.value as? OutlineViewRow {
			return value.children[index]
		} else if let item = item as? OutlineViewRow {
			return item.children[index]
		}
		return 0
	}
	
	public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let item = item as? OutlineViewRow {
			return item.children.count > 0 || item.value is OutlineViewRow
		}
		return false
	}
}

extension DeviceReportsViewController: NSOutlineViewDelegate {
	
	// MARK: NSOutlineViewDelegate Implementation
	
	public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		if tableColumn?.identifier.rawValue == "Name" {
			let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DeviceReportCellName"), owner: self) as? NSTableCellView
			
			var text = ""
			if let item = item as? OutlineViewRow {
				text = item.key
			}
			
			view?.textField?.stringValue = text
			view?.textField?.sizeToFit()
			return view
		} else if tableColumn?.identifier.rawValue == "Value" {
			let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DeviceReportCellValue"), owner: self) as? NSTableCellView
			
			var text = ""
			if let item = item as? OutlineViewRow, item.value != nil {
				text = String(describing: item.value)
			}
			
			view?.textField?.stringValue = text
			view?.textField?.sizeToFit()
			return view
		}
		
		return nil
	}
}

fileprivate extension OutlineViewRow {
	
	// MARK: Custom OutlineViewRow overrides
	
	convenience init(deviceReport: DeviceReport) {
		self.init(key: "HID Report", value: nil, children: [
			OutlineViewRow(key: "Timestamp", value: deviceReport.timestamp, children: []),
			OutlineViewRow(key: "Report Type", value: deviceReport.reportType, children: []),
			OutlineViewRow(key: "Report ID", value: deviceReport.reportId, children: []),
			OutlineViewRow(key: "Report Data", value: deviceReport.report, children: []),
			OutlineViewRow(key: "HID Values", value: nil, children: deviceReport.hidValues.map { OutlineViewRow(hidValue: $0) }),
		])
	}
	
	convenience init(hidValue: HIDValue) {
		self.init(key: "HID Value", value: nil, children: [
			OutlineViewRow(key: "Length", value: hidValue.length, children: []),
			OutlineViewRow(key: "Integer Value", value: hidValue.integerValue, children: []),
			OutlineViewRow(key: "Scaled Value (calibrated)", value: hidValue.getScaledValue(type: .calibrated), children: []),
			OutlineViewRow(key: "Scaled Value (exponent)", value: hidValue.getScaledValue(type: .exponent), children: []),
			OutlineViewRow(key: "Scaled Value (physical)", value: hidValue.getScaledValue(type: .physical), children: []),
			OutlineViewRow(key: "HID Element", value: OutlineViewRow(hidElement: hidValue.element), children: [])
		])
	}
	
	convenience init(hidElement: HIDElement) {
		self.init(key: "HID Element", value: nil, children: [
			OutlineViewRow(key: "Cookie", value: hidElement.cookie, children: []),
			OutlineViewRow(key: "Name", value: hidElement.name, children: []),
			OutlineViewRow(key: "Type", value: hidElement.type, children: []),
			OutlineViewRow(key: "Collection Type", value: hidElement.collectionType, children: []),
			OutlineViewRow(key: "Usage", value: hidElement.usage, children: []),
			OutlineViewRow(key: "Is Virtual", value: hidElement.isVirtual, children: []),
			OutlineViewRow(key: "Is Relative", value: hidElement.isRelative, children: []),
			OutlineViewRow(key: "Is Wrapping", value: hidElement.isWrapping, children: []),
			OutlineViewRow(key: "Is Array", value: hidElement.isArray, children: []),
			OutlineViewRow(key: "Is Non-Linear", value: hidElement.isNonLinear, children: []),
			OutlineViewRow(key: "Has Preferred State", value: hidElement.hasPreferredState, children: []),
			OutlineViewRow(key: "Has Null State", value: hidElement.hasNullState, children: []),
			OutlineViewRow(key: "Unit", value: hidElement.unit, children: []),
			OutlineViewRow(key: "Unit Exponent", value: hidElement.unitExponent, children: []),
			OutlineViewRow(key: "Logical Min", value: hidElement.logicalMin, children: []),
			OutlineViewRow(key: "Logical Max", value: hidElement.logicalMax, children: []),
			OutlineViewRow(key: "Physical Min", value: hidElement.physicalMin, children: []),
			OutlineViewRow(key: "Physical Max", value: hidElement.physicalMax, children: []),
			OutlineViewRow(key: "Children", value: nil, children: hidElement.children?.map { OutlineViewRow(hidElement: $0) } ?? [])
		])
	}
}

//
//  DeviceViewModel.swift
//  HIDUtil
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation
import SwiftyHID

class DeviceReport {
	var timestamp: UInt64
	
	var reportType: SwiftyHID.HIDReportType?
	var reportId: UInt32?
	var report: Data?
	
	var hidValues: [HIDValue] = []
	
	init(withTimestamp timestamp: UInt64) {
		self.timestamp = timestamp
	}
}

struct DescriptorItemWrapper {
	let descriptorItem: HIDDescriptorItem
	let descriptorData: HIDDescData
	let tabIndex: Int
	let overrideUsage: String?
}

enum LexedDescriptorStatus {
	case success
	case noDescriptorData
	case error
}

class DeviceViewModel {
	
	// MARK: Dynamic Properties
	
	var reportDescriptor: Dynamic<Data> = Dynamic(Data())
	var lexedReportDescriptor: Dynamic<[DescriptorItemWrapper]> = Dynamic([])
	var lexedReportDescriptorStatus = Dynamic(LexedDescriptorStatus.noDescriptorData)
	var deviceReports: Dynamic<[DeviceReport]> = Dynamic([])
	
	// MARK: Initialization
	
	var device: HIDDevice {
		didSet {
			refreshDevice()
		}
	}
	
	let semaphore = DispatchSemaphore(value: 1)
	private var deviceReportsDic: [UInt64: DeviceReport] = [:]
	
	init(withDevice dev: HIDDevice) {
		device = dev
		refreshDevice()
	}
	
	private func refreshDevice() {
		reportDescriptor.value = device.reportDescriptor ?? Data()
		
		prepareDeviceDescriptor()
		
		// Input Reports
		device.register(inputReportWithTimestampCallback: { [weak self] (result, device, reportType, reportId, report, timestamp) in
			print(result, device.product as Any, reportType, reportId, report, timestamp)
			guard let self = self else { return }
			
			// Reports come in first. Create a wrapper object. See below.
			self.semaphore.sync {
				let deviceReport = self.getDeviceReport(withTimestamp: timestamp)
				deviceReport.reportType = reportType
				deviceReport.reportId = reportId
				deviceReport.report = report
			}
			self.deviceReports.fire()
		})
		
		// Input Values
		device.register(inputValueCallback: { [weak self] (result, queue, value) in
			print(result, queue, value)
			guard let self = self else { return }
			
			// Values come in after reports. Add them to the wrapper created above.
			self.semaphore.sync {
				let deviceReport = self.getDeviceReport(withTimestamp: value.timestamp)
				deviceReport.hidValues.append(value)
			}
			self.deviceReports.fire()
		})
	}
	
	private func getDeviceReport(withTimestamp timestamp: UInt64) -> DeviceReport {
		guard let deviceReport = self.deviceReportsDic[timestamp] else {
			let report = DeviceReport(withTimestamp: timestamp)
			self.deviceReports.value.append(report)
			self.deviceReportsDic[timestamp] = report
			return report
		}
		return deviceReport
	}
	
	private func prepareDeviceDescriptor() {
		// Prepare lexed descriptor items
		
		// Make sure we have actual data
		guard let descriptorData = device.reportDescriptor else {
			lexedReportDescriptor.value = []
			lexedReportDescriptorStatus.value = .noDescriptorData
			return
		}

		var wrappedItems: [DescriptorItemWrapper] = []
		var tabIndex = 0
		var usagePageStack: [UInt32] = [0]
		// Perform the regular lexing/parsing
		guard let lexedItems = try? HIDDescLexer.parse(descriptorData: descriptorData) else {
			lexedReportDescriptor.value = []
			lexedReportDescriptorStatus.value = .noDescriptorData
			return
		}
		
		// Provide wrapper information for better human consumption.
		// Collection begin/end: add/delete indents.
		// Usage Pages/Usages: use the actual name. Use a stack to remember the last one used for push/pop.
		for item in lexedItems {
			var overrideText: String?
			switch item.0 {
			case .main(.endCollection):
				tabIndex -= 1
			case .global(.usagePage(let usagePage)):
				usagePageStack[usagePageStack.endIndex - 1] = usagePage
			case .global(.push):
				usagePageStack.append(usagePageStack.last ?? 0)
			case .global(.pop):
				let _ = usagePageStack.popLast()
			case .local(.usage(let usage)):
				let usagePageUsage = Usage(withUsagePage: Int(usagePageStack.last ?? 0), usage: Int(usage))
				overrideText = "\(usagePageUsage)"
			default:
				break
			}
			
			wrappedItems.append(DescriptorItemWrapper(
				descriptorItem: item.0,
				descriptorData: item.1,
				tabIndex: tabIndex,
				overrideUsage: overrideText))
			
			switch item.0 {
			case .main(.beginCollection):
				tabIndex += 1
			default:
				break
			}
		}
		
		lexedReportDescriptor.value = wrappedItems
		lexedReportDescriptorStatus.value = .success
	}
}

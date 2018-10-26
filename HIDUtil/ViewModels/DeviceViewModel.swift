//
//  DeviceViewModel.swift
//  JoyConManager
//
//  Created by James Linnell on 10/21/18.
//  Copyright © 2018 James Linnell. All rights reserved.
//

import Foundation
import SwiftyHID

class DeviceReport {
	var timestamp: UInt64
	
	var reportType: HIDReportType?
	var reportId: UInt32?
	var report: Data?
	
	var hidValues: [HIDValue] = []
	
	init(withTimestamp timestamp: UInt64) {
		self.timestamp = timestamp
	}
}

class DeviceViewModel {
	
	// MARK: Dynamic Properties
	
	var reportDescriptor: Dynamic<Data> = Dynamic(Data())
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
		
		device.register(inputReportWithTimestampCallback: { [weak self] (result, device, reportType, reportId, report, timestamp) in
			print(result, device.product as Any, reportType, reportId, report, timestamp)
			guard let self = self else { return }
			
			self.semaphore.sync {
				let deviceReport = self.getDeviceReport(withTimestamp: timestamp)
				deviceReport.reportType = reportType
				deviceReport.reportId = reportId
				deviceReport.report = report
			}
			self.deviceReports.fire()
		})
		device.register(inputValueCallback: { [weak self] (result, queue, value) in
			print(result, queue, value)
			guard let self = self else { return }
			
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
}

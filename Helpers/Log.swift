//
//  Log.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

private struct LogSettings {

	static var shouldShowDetailedLogs	: Bool = true
	static var detailedLogFormat		= ">>> :className.:function.:line: :obj"
	static var detailedLogDateFormat	= "yyyy-MM-dd HH:mm:ss.SSS"
	static fileprivate var dateFormatter	: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = LogSettings.detailedLogDateFormat
		return formatter
	}
}

struct Log {

	enum Verbose {
		case pinAddress
		case api
		case analytics
		case error

		var isEnabled: Bool {
			switch self {
			case .pinAddress:	return false
			case .api:			return false
			case .analytics:	return false
			case .error:		return true
			}
		}
	}

	@discardableResult
	init(_ verbose: Log.Verbose, _ obj: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
		guard (verbose.isEnabled == true && Configuration.isLogEnabled == true) else {
			return
		}

		guard
			(LogSettings.shouldShowDetailedLogs == true),
			let className = NSURL(string: file)?.lastPathComponent?.components(separatedBy: ".").first else {
				print(obj)
				return
		}

		var logStatement = LogSettings.detailedLogFormat.replacingOccurrences(of: ":line", with: "\(line)")
		logStatement = logStatement.replacingOccurrences(of: ":className", with: className)
		logStatement = logStatement.replacingOccurrences(of: ":function", with: function)
		logStatement = logStatement.replacingOccurrences(of: ":obj", with: "\(obj)")

		if (logStatement.contains(":date")) {
			let replacement = LogSettings.dateFormatter.string(from: Date())
			logStatement = logStatement.replacingOccurrences(of: ":date", with: "\(replacement)")
		}

		print(logStatement)
	}
}

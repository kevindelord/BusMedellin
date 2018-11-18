//
//  DKLog.swift
//  BusMedellin
//
//  Created by kevindelord on 26/08/2018.
//  Copyright © 2018 Kevin Delord. All rights reserved.
//

import Foundation

struct DKLogSettings {

	static var shouldShowDetailedLogs	: Bool = true
	static var detailedLogFormat		= ">>> :line :className.:function --> :obj"
	static var detailedLogDateFormat	= "yyyy-MM-dd HH:mm:ss.SSS"
	static fileprivate var dateFormatter	: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = DKLogSettings.detailedLogDateFormat
		return formatter
	}
}

func DKLog(_ verbose: Bool, _ obj: Any = "", file: String = #file, function: String = #function, line: Int = #line) {
	guard (verbose == true) else {
		return
	}

	guard
		(DKLogSettings.shouldShowDetailedLogs == true),
		let className = NSURL(string: file)?.lastPathComponent?.components(separatedBy: ".").first else {
			print(obj)
			return
	}

	var logStatement = DKLogSettings.detailedLogFormat.replacingOccurrences(of: ":line", with: "\(line)")
	logStatement = logStatement.replacingOccurrences(of: ":className", with: className)
	logStatement = logStatement.replacingOccurrences(of: ":function", with: function)
	logStatement = logStatement.replacingOccurrences(of: ":obj", with: "\(obj)")

	if (logStatement.contains(":date")) {
		let replacement = DKLogSettings.dateFormatter.string(from: Date())
		logStatement = logStatement.replacingOccurrences(of: ":date", with: "\(replacement)")
	}

	print(logStatement)
}

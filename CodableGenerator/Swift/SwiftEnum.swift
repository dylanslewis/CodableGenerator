//
//  SwiftEnum.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

struct SwiftEnum: SwiftType {
	let name: String
	let swiftType: SwiftObject
	let protocols: [String]
	let swiftCases: [SwiftCase]
	var parentTypes: [SwiftType]
	
	init(name: String, swiftType: SwiftObject, protocols: [String], swiftCases: [SwiftCase], parentTypes: [SwiftType]) {
		self.name = name.swiftyPropertyName
		self.swiftType = swiftType
		self.protocols = protocols
		self.swiftCases = swiftCases
		self.parentTypes = parentTypes
	}
}

extension SwiftEnum {
	struct SwiftCase {
		let name: String
		let value: String?
		
		init(name: String, value: String?) {
			self.name = name.swiftyPropertyName
			self.value = name == value ? nil : value
		}
	}
}

extension SwiftEnum {
	var swiftCodeLines: [SwiftCodeLine] {
		if protocols == ["CodingKey"], swiftCases.filter({ $0.value != nil }).isEmpty {
			return []
		}
		
		var swiftCodeLines: [SwiftCodeLine] = [.emptyLine]
		
		if !parentTypes.isEmpty {
			swiftCodeLines.append(.init(code: "extension \(parentTypes.map({ $0.name }).joined(separator: ".")) {"))
		}
		
		let swiftTypeAndProtocols = [swiftType.stringRepresentation] + protocols
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "enum \(name): \(swiftTypeAndProtocols.joined(separator: ", ")) {"))
		swiftCases.forEach { (arg) in
			let swiftCase = arg
			if let value = swiftCase.value {
				swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel + 1, code: "case \(swiftCase.name) = \"\(value)\""))
			} else {
				swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel + 1, code: "case \(swiftCase.name)"))
			}
		}
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "}"))
		
		if let extensionClosing = self.extensionClosing {
			swiftCodeLines.append(extensionClosing)
		}
		
		return swiftCodeLines
	}
}

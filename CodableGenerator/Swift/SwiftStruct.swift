//
//  SwiftStruct.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

struct SwiftStruct: SwiftType {
	let name: String
	let protocols: [String]
	let properties: [SwiftProperty]
	var parentTypes: [SwiftType]
	
	init(name: String, protocols: [String] = [], properties: [SwiftProperty] = [], parentTypes: [SwiftType] = []) {
		self.name = name.swiftyTypeName
		self.protocols = protocols
		self.properties = properties
		self.parentTypes = parentTypes
	}
	
	// Init for Codable
	init(name: String, typeForKey: [String: SwiftObject], parentTypes: [SwiftType] = []) {
		var properties: [SwiftProperty] = []
		typeForKey.enumerated().forEach { (arg) in
			let (_, keyAndValue) = arg
			let key = keyAndValue.key
			let type = keyAndValue.value
			let property = SwiftProperty(key: key, type: type)
			properties.append(property)
		}
		self.init(name: name, protocols: ["Codable"], properties: properties, parentTypes: parentTypes)
	}
	
	init(name: String, rawDictionary: [String: Any], parentTypes: [SwiftType] = []) {
		var properties: [SwiftProperty] = []
		rawDictionary.enumerated().forEach { (arg) in
			let (_, keyAndValue) = arg
			let key = keyAndValue.key
			let value = keyAndValue.value
			let type = SwiftObject(key: key, value: value)
			let property = SwiftProperty(key: key, type: type)
			properties.append(property)
		}
		self.init(name: name, protocols: ["Codable"], properties: properties, parentTypes: parentTypes)
	}
}

extension SwiftStruct {
	var swiftCodeLines: [SwiftCodeLine] {
		var swiftCodeLines: [SwiftCodeLine] = [.emptyLine]
		
		if let extensionOpening = self.extensionOpening {
			swiftCodeLines.append(extensionOpening)
		}
		
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "struct \(name): \(protocols.joined(separator: ",")) {"))
		properties
			.map({ return .init(indentationLevel: baseIndentationLevel + 1, code: "let \($0.key): \($0.type.stringRepresentation)") })
			.forEach({ swiftCodeLines.append($0) })
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "}"))
		
		if let extensionClosing = self.extensionClosing {
			swiftCodeLines.append(extensionClosing)
		}
		return swiftCodeLines
	}
}

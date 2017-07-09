//
//  JSONType.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

struct JSONType {
	let name: String
	let typeForKey: [String: SwiftObject]
	let subtypes: [JSONType]
}

extension JSONType {
	var swiftCodeRepresentation: String {
		// FIXME: Do some sorting on types and similarity recognition
		
		return codableSwiftTypes()
			.flatMap({ $0.swiftCodeLines })
			.map({ String(repeating: .tab, count: $0.indentationLevel) + $0.code })
			.joined(separator: .newLine)
	}
	
	private func codableSwiftTypes(parentTypes: [SwiftType] = []) -> [SwiftType] {
		let swiftStruct = SwiftStruct(name: name, typeForKey: typeForKey, parentTypes: parentTypes)
		let swiftCodingKeyCases = typeForKey.enumerated().map({ SwiftEnum.SwiftCase(name: $0.element.key.swiftyPropertyName, value: $0.element.key) })
		let swiftCodingKeys = SwiftEnum(name: "CodingKeys",
		                                swiftType: "String",
		                                protocols: ["CodingKey"],
		                                swiftCases: swiftCodingKeyCases,
		                                parentTypes: parentTypes + [swiftStruct])
		
		let swiftSubtypes = subtypes.flatMap({ $0.codableSwiftTypes(parentTypes: parentTypes + [swiftStruct]) })
		
		let propertyTypes: [SwiftType] = swiftStruct.properties.flatMap { property in
			switch property.type {
			case .array(let type):
				if case .custom(let swiftStruct) = type {
					return swiftStruct
				}
			case .custom(let swiftStruct):
				return swiftStruct
			default:
				break
			}
			return nil
		}
		return [swiftStruct, swiftCodingKeys] + propertyTypes + swiftSubtypes
	}
}

typealias KeyAndValue = (key: String, value: Any)

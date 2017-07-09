//
//  SwiftObjectType.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

/// The type of a Swift object.
indirect enum SwiftObject {
	case string
	case integer
	case double
	case boolean
	case null
	case custom(swiftStruct: SwiftStruct)
	case array(type: SwiftObject)
	case unknown
	// FIXME: Handle Date

	init(key: String, value: Any) {
		assert(!(value is SwiftObject))
		if let _ = value as? String {
			self = .string
		} else if let _ = value as? Int {
			self = .integer
		} else if let _ = value as? Bool {
			self = .boolean
		} else if let _ = value as? Double {
			self = .double
		} else if
			let arrayValue = value as? [Any],
			let firstArrayValue = arrayValue.first
		{
			let swiftObjectType = SwiftObject(key: key, value: firstArrayValue)
			self = .array(type: swiftObjectType)
		} else if let dictionaryValue = value as? [String: Any] {
			let swiftStruct = SwiftStruct(name: key, rawDictionary: dictionaryValue)
			self = .custom(swiftStruct: swiftStruct)
		} else {
			// Can't parse this.
			//			print("Unable to parse \(key): \(value)")
			self = .unknown
		}
	}
}

extension SwiftObject {
	var stringRepresentation: String {
		switch self {
		case .boolean:
			return "Bool"
		case .double:
			return "Double"
		case .integer:
			return "Int"
		case .null:
			return "NSNull"
		case .string:
			return "String"
		case .array(let type):
			return "[\(type.stringRepresentation)]"
		case .custom(let swiftStruct):
			return swiftStruct.name
		case .unknown:
			return "Unknown"
		}
	}
}


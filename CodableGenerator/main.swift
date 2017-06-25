//
//  main.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 24/06/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

// FIXME: Add hide file header option
// FIXME: Add spaces or tabs option
// FIXME: Add subtypes in extensions option
// FIXME: Remove duplicates option

// MARK: - Helpers

extension String {
	struct ParsingError: Error { }
	
	func dictionaryRepresentation() throws -> [String: Any] {
		guard let data = self.data(using: .utf8) else {
			throw ParsingError()
		}
		let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
		guard let dictionary = jsonObject as? [String: Any] else {
			throw ParsingError()
		}
		return dictionary
	}
}



//		swiftCode.append("\n//  \(name).swift")
//		swiftCode.append("\n//  Created by CodableGenerator")
//		swiftCode.append("\n//  FIXME: Add GitHub page")
//		swiftCode.append("\n//")


// FIXME: Get raw JSON from file
// FIXME: Get raw JSON from clipboard
// FIXME: Get raw JSON from website

// FIXME: Add Float
// FIXME: Add array
// FIXME: Add date
// FIXME: Add NSNull
let simpleExample = """
{
	"rootLevel": "Root level",
	"LevelOne": {
		"levelOneString": "String",
		"LevelTwo": {
			"levelTwoString": "String"
		}
	},
	"flatTypeArray": [1, 2, 3],
	"jsonTypeArray": [{
		"a": "aay",
		"b": "bee"
	},
	{
		"a": "aay",
		"c": "cee"
	}],
	"arrayOfArray": [
		[1,2],
		[3,4]
	],
	"rootLevelString": "String",
	"rootLevelInt": 1,
	"duplicatedLevelOne": {
		"levelOneString": "String",
		"LevelTwo": {
			"levelTwoString": "String"
		}
	}
}
"""

// FIXME: Need to handle the shitty Hue API which has numbers as keys...
// in that case it might be best to re-write it as an array, because then
// you can get the types listed as the same type.
// Codable would struggle with this case too, because it would need to be
// converted to an arrya. Therefore, maybe it's good to have a Hue JSON parser
// as a piece of middleware, before it gets to this parser, before it gets
// parsed in the app.

// It seems quite common to have an array of [ID: SomeType], so in this case,
// the parser will need to look within the values and identify the same ones...

// For the Hue case, maybe it would be better to have an option to place top level
// objects in an array

// When doing this, take the array key name and try to unpluralize it, maybe
// this will require input from the user.

extension String {
	var swiftyPropertyName: String {
		// FIXME: Create a Swifty version
		return self
	}
	
	var swiftyTypeName: String {
		// FIXME: Create a Swifty version
		return self
	}
	
	static let tab: String = "\t"
	static let newLine: String = "\n"
}

typealias KeyAndType = (key: String, type: Any)

struct JSONType {
	let name: String
	let keysAndTypes: [KeyAndType]
	let subtypes: [JSONType]
}

struct SwiftCodeLine {
	let indentationLevel: Int
	let code: String
	
	init(indentationLevel: Int = 0, code: String) {
		self.indentationLevel = indentationLevel
		self.code = code
	}
	
	static let emptyLine: SwiftCodeLine = .init(code: "")
}

protocol SwiftType {
	var name: String { get }
	var swiftCodeLines: [SwiftCodeLine] { get }
	var protocols: [String] { get }
	var parentTypes: [SwiftType] { get }
}

extension SwiftType {
	var extensionOpening: SwiftCodeLine? {
		guard !parentTypes.isEmpty else {
			return nil
		}
		return .init(code: "extension \(parentTypes.map({ $0.name }).joined(separator: ".")) {")
	}
	var extensionClosing: SwiftCodeLine? {
		guard !parentTypes.isEmpty else {
			return nil
		}
		return .init(code: "}")
	}
	var baseIndentationLevel: Int {
		return parentTypes.isEmpty ? 0 : 1
	}
}

struct SwiftStruct: SwiftType {
	let name: String
	let protocols: [String]
	let properties: [KeyAndType]
	var parentTypes: [SwiftType]
	
	init(name: String, protocols: [String], properties: [KeyAndType], parentTypes: [SwiftType]) {
		self.name = name.swiftyTypeName
		self.protocols = protocols
		self.properties = properties.map({ (key: $0.key.swiftyPropertyName, type: $0.type) })
		self.parentTypes = parentTypes
	}
}

extension SwiftStruct {
	var swiftCodeLines: [SwiftCodeLine] {
		var swiftCodeLines: [SwiftCodeLine] = [.emptyLine]
		
		if let extensionOpening = self.extensionOpening {
			swiftCodeLines.append(extensionOpening)
		}
			
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "struct \(name): \(protocols.joined(separator: ",")) {"))
		properties.forEach { (arg: (key: String, type: Any)) in
			let (key, type) = arg
			swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel + 1, code: "let \(key.swiftyPropertyName): \(type)"))
		}
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "}"))
		
		if let extensionClosing = self.extensionClosing {
			swiftCodeLines.append(extensionClosing)
		}
		
		return swiftCodeLines
	}
}

struct SwiftEnum: SwiftType {
	let name: String
	let swiftType: String // FIXME: Make generic with T
	let protocols: [String]
	let swiftCases: [SwiftCase]
	var parentTypes: [SwiftType]
	
	init(name: String, swiftType: String, protocols: [String], swiftCases: [SwiftCase], parentTypes: [SwiftType]) {
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
			
		let swiftTypeAndProtocols = [swiftType] + protocols
		swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel, code: "enum \(name): \(swiftTypeAndProtocols.joined(separator: ", ")) {"))
		swiftCases.forEach { (arg) in
			let swiftCase = arg
			if let value = swiftCase.value {
				swiftCodeLines.append(.init(indentationLevel: baseIndentationLevel + 1, code: "case \(swiftCase.name): \(value)"))
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



extension JSONType {
	var swiftCodeRepresentation: String {
		// FIXME: Do some sorting on types and similarity recognition
		
		let allSwiftTypes = codableSwiftTypes()
		
		let removedAndReplacedSwiftType: [(SwiftType, SwiftType)] = []
		
		allSwiftTypes.forEach { swiftType in
			if let swiftStruct = swiftType as? SwiftStruct {
				let otherSwiftStructs = allSwiftTypes.flatMap({ $0 as? SwiftStruct })
				
			}
		}
		
		return codableSwiftTypes()
			.flatMap({ $0.swiftCodeLines })
			.map({ String(repeating: .tab, count: $0.indentationLevel) + $0.code })
			.joined(separator: .newLine)
	}
	
	private func codableSwiftTypes(parentTypes: [SwiftType] = []) -> [SwiftType] {
		let swiftStruct = SwiftStruct(name: name,
		                              protocols: ["Codable"],
		                              properties: keysAndTypes,
		                              parentTypes: parentTypes)
		
		let swiftCodingKeyCases = keysAndTypes.map({ SwiftEnum.SwiftCase(name: $0.key.swiftyPropertyName, value: $0.key) })
		let swiftCodingKeys = SwiftEnum(name: "CodingKeys",
		                                swiftType: "String",
		                                protocols: ["CodingKey"],
		                                swiftCases: swiftCodingKeyCases,
		                                parentTypes: parentTypes + [swiftStruct])
		
		let swiftSubtypes = subtypes.flatMap({ $0.codableSwiftTypes(parentTypes: parentTypes + [swiftStruct]) })
		
		return [swiftStruct, swiftCodingKeys] + swiftSubtypes
	}
}

typealias KeyAndValue = (key: String, value: Any)

// FIXME: Think if you want to handle arrays of different types... it counts as valid JSON. It surely can't be Codable
// Answer: If all the objects inside the array conform to `Decodable`, it's ok

//extension Array {
//	var containsSameType: Bool {
//		guard let firstElement = first else {
//			return true
//		}
//		return filter({ $0.Type == type(of: firstElement) }).count == count
//	}
//}

func typeString(withParentTypeName name: String, keyAndValue: KeyAndValue) -> String {
	let key = keyAndValue.key
	let value = keyAndValue.value
	
	switch value {
	case is [String: Any]:
		// This will need to be a lot smarter, and really understand what
		// the type is at this point, for the case of an array of dictionaries
		// where the value of each dictionary is the same...
		return key.swiftyPropertyName
	case is [[String: Any]]:
		// This is the special case.
		return "[ArrayOfDictionaries]"
	case is [Any]:
		// If there are multiple types in here, they all need to be Decodable
		return "[Array]"
		//		return "[" + typeString(withParentTypeName: name, keyAndValue: keyAndValue) + "]"
	case is String:
		return String(describing: String.self)
	case is Int:
		return String(describing: Int.self)
	default:
		return String(describing: type(of: value))
	}
}

func jsonType(withName name: String, rawJSONDictionary: [String: Any]) -> JSONType {
	var keysAndTypes: [KeyAndType] = []
	var subtypes: [JSONType] = []
	
	rawJSONDictionary.enumerated().forEach { (arg) in
		let (_, keyAndValue) = arg
		let key = keyAndValue.key
		let value = keyAndValue.value
		
		let type = typeString(withParentTypeName: name, keyAndValue: keyAndValue)
		if let dictionaryValue = value as? [String: Any] {
			let subtype = jsonType(withName: key.swiftyPropertyName, rawJSONDictionary: dictionaryValue)
			subtypes.append(subtype)
		}
		
		// FIXME: Handle Double/Float
		// FIXME: Handle Date
		// FIXME: Handle array, which will require looking through all the objecst and creating a concatenated one with as many types as possible
		keysAndTypes.append((key, type))
	}
	
	return .init(name: name, keysAndTypes: keysAndTypes, subtypes: subtypes)
}

func swiftStruct(withName name: String, jsonString: String) throws -> String {
	let rawJSONDictionary = try simpleExample.dictionaryRepresentation()
	return jsonType(withName: name, rawJSONDictionary: rawJSONDictionary).swiftCodeRepresentation
}

// FIXME: Handle root level array

let typeName = "SampleJSON"

guard let simpleExampleStruct = try? swiftStruct(withName: typeName, jsonString: simpleExample) else {
	print("Unable to parse JSON")
	exit(1)
}

print(simpleExampleStruct)

// FIXME: Export to file
// FIXME: Add AppleScript

//
//  main.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 24/06/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

// MARK: - Options

// FIXME: Add hide file header option
// FIXME: Add spaces or tabs option
// FIXME: Add subtypes in extensions option
// FIXME: Remove duplicates option

// MARK: - Input types

// FIXME: Get raw JSON from file
// FIXME: Get raw JSON from clipboard
// FIXME: Get raw JSON from website

// MARK: - Parsing

// FIXME: Handle root level array
// FIXME: Add Float
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
	"hueArray": {
		"1": {
			"name": "Name",
			"value": 1
		},
		"2": {
			"name": "Name",
			"value": 1
		}
	},
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

// FIXME: Think if you want to handle arrays of different types... it counts as valid JSON. It surely can't be Codable
// Answer: If all the objects inside the array conform to `Decodable`, it's ok
// So basically, parse and create a type for each object in the array, try and do similarity analysis on them, and if there is > 1 type, put the type of the array as Decodable, put have extensions for each of the types contained within it.

func jsonType(withName name: String, rawJSONDictionary: [String: Any]) -> JSONType {
	var typeForKey: [String: SwiftObject] = [:]
	var subtypes: [JSONType] = []
	
	rawJSONDictionary.enumerated().forEach { (arg) in
		let (_, keyAndValue) = arg
		let key = keyAndValue.key
		let value = keyAndValue.value
		
		if let dictionaryValue = value as? [String: Any] {
			let subtype = jsonType(withName: key, rawJSONDictionary: dictionaryValue)
			subtypes.append(subtype)
		}

		let type = SwiftObject(key: key, value: value)
		typeForKey[key] = type
	}
	return .init(name: name, typeForKey: typeForKey, subtypes: subtypes)
}

func swiftStruct(withName name: String, jsonString: String) throws -> String {
	let rawJSONDictionary = try simpleExample.dictionaryRepresentation()
	return jsonType(withName: name, rawJSONDictionary: rawJSONDictionary).swiftCodeRepresentation
}

let typeName = "SampleJSON"

guard let simpleExampleStruct = try? swiftStruct(withName: typeName, jsonString: simpleExample) else {
	print("Unable to parse JSON")
	exit(1)
}

print(simpleExampleStruct)

// FIXME: Export to file
// FIXME: Add AppleScript

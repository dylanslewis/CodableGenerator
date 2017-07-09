//
//  String+Swift.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

extension String {
	var swiftyPropertyName: String {
		guard let firstCharacter = first else {
			return self
		}
		// FIXME: Deal with _
		let swiftyPropertyName = replacingCharacters(in: startIndex..<index(after: startIndex), with: String(describing: firstCharacter).lowercased())
		return swiftyPropertyName
	}
	
	var swiftyTypeName: String {
		guard let firstCharacter = first else {
			return self
		}
		// FIXME: Deal with _
		let swiftyPropertyName = replacingCharacters(in: startIndex..<index(after: startIndex), with: String(describing: firstCharacter).uppercased())
		return swiftyPropertyName
	}
}

extension String {
	static let tab: String = "\t"
	static let newLine: String = "\n"
}

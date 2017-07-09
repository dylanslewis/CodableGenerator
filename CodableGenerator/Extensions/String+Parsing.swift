//
//  String+Parsing.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

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

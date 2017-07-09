//
//  SwiftCodeLine.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

struct SwiftCodeLine {
	let indentationLevel: Int
	let code: String
	
	init(indentationLevel: Int = 0, code: String) {
		self.indentationLevel = indentationLevel
		self.code = code
	}
}

extension SwiftCodeLine {
	static let emptyLine: SwiftCodeLine = .init(code: "")
}

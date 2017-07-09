//
//  SwiftType.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

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

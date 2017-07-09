//
//  SwiftProperty.swift
//  CodableGenerator
//
//  Created by Dylan Lewis on 09/07/2017.
//  Copyright © 2017 Dylan Lewis. All rights reserved.
//

import Foundation

struct SwiftProperty {
	let isMutable: Bool
	let key: String
	let type: SwiftObject
	
	init(isMutable: Bool = false, key: String, type: SwiftObject) {
		self.isMutable = isMutable
		self.key = key
		self.type = type
	}
}

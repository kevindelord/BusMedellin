//
//  FailableCodableArray.swift
//  BusMedellin
//
//  Created by kevindelord on 06/10/2019.
//  Copyright © 2019 Kevin Delord. All rights reserved.
//
// Logic found on StackOverflow:
// https://stackoverflow.com/questions/46344963/swift-jsondecode-decoding-arrays-fails-if-single-element-decoding-fails

struct FailableCodableArray<Element : Codable> : Codable {

	var elements: [Element]

	init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()

		var elements = [Element]()
		if let count = container.count {
			elements.reserveCapacity(count)
		}

		while !container.isAtEnd {
			if let element = try container.decodeIfPresent(Element.self) {
				elements.append(element)
			}
		}

		self.elements = elements
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(elements)
	}
}

//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

@testable import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
	func test_map_throwsErrorOnNon200HTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 300, 400, 500]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() {
		let invalidJSON = Data("invalid json".utf8)

		let samples = [200, 201, 250, 280, 299]

		try? samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
		let item1 = makeItem(
			id: UUID(),
			message: "a message",
			createdAt: Date(),
			username: "a username")

		let item2 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: Date(),
			username: "a long username")

		let json = makeItemsJSON([item1.json, item2.json])

		let samples = [200, 201, 250, 280, 299]

		try samples.forEach { code in
			let result = try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			XCTAssertEqual(result, [item1.model, item2.model])
		}
	}

	func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])

		let samples = [200, 201, 250, 280, 299]

		try samples.forEach { code in
			let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
			XCTAssertEqual(result, [])
		}
	}

	// MARK: - Helpers

	private func makeItem(id: UUID, message: String, createdAt: Date, username: String) -> (model: ImageComment, json: [String: Any]) {
		let dateFormatter = ISO8601DateFormatter()
		let stringDate = dateFormatter.string(from: createdAt)

		let item = ImageComment(id: id,
		                        message: message,
		                        createdAt: dateFormatter.date(from: stringDate)!,
		                        authorUsername: username)
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": stringDate,
			"author": ["username": username]
		]

		return (item, json)
	}
}

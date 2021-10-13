//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest

@testable import EssentialFeed

class ImageCommentsMapperTests: XCTestCase {
	func test_map_throwsErrorOnNon200HTTPResponse() throws {
		let json = makeItemsJSON([])
		let samples = [199, 201, 300, 400, 500]

		try samples.forEach { code in
			XCTAssertThrowsError(
				try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: code))
			)
		}
	}

	func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
		let invalidJSON = Data("invalid json".utf8)

		XCTAssertThrowsError(
			try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
		)
	}

	func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
		let emptyListJSON = makeItemsJSON([])

		let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

		XCTAssertEqual(result, [])
	}

	func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
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

		let result = try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: 200))

		XCTAssertEqual(result, [item1.model, item2.model])
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

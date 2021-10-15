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
		let date = (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00")
		let item1 = makeItem(
			id: UUID(),
			message: "a message",
			createdAt: date,
			username: "a username")

		let item2 = makeItem(
			id: UUID(),
			message: "another message",
			createdAt: date,
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

	private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
		let item = ImageComment(id: id,
		                        message: message,
		                        createdAt: createdAt.date,
		                        authorUsername: username)
		let json: [String: Any] = [
			"id": id.uuidString,
			"message": message,
			"created_at": createdAt.iso8601String,
			"author": ["username": username]
		]

		return (item, json)
	}
}
